# encoding: utf-8

# Classes concerning command execution
module CommandExec
  # Run commands
  class Command

    attr_accessor :log_file, :options , :parameter, :error_keywords
    attr_reader :result, :path, :working_directory

    # Create a new command to execute
    #
    # @param [Symbol] name name of command
    # @param [optional,Hash] opts options for the command
    # @option opts [String] :options options for binary
    # @option opts [String] :parameter parameter for binary
    # @option opts [String] :error_keywords keyword indicating an error on stdout
    # @option opts [String] :working_directory working directory where the process should run in
    # @option opts [String] :log_file file path to log file of process
    # @option opts [String] :log_level level of information in output
    # @option opts [String] :search_paths Paths where to look for executable
    def initialize(name,opts={})

      @name = name
      @opts = {
        :logger => Logger.new($stderr),
        :options => '',
        :parameter => '',
        :error_keywords => [],
        :working_directory => Dir.pwd,
        :log_file => '',
        :log_level => :info,
        :search_paths => ENV['PATH'].split(':'),
      }.update opts


      @logger = @opts[:logger] 
      @options = @opts[:options]
      @parameter = @opts[:parameter]
      @path = resolve_cmd_name(name, @opts[:search_paths])
      @error_keywords = @opts[:error_keywords]
      @log_file = @opts[:log_file]

      configure_logging @opts[:log_level]

      @working_directory = @opts[:working_directory] 
      @result = nil
    end

    private

    def configure_logging(log_level)
      case log_level
      when :debug
        @logger.level = Logger::DEBUG
      when :error
        @logger.level = Logger::ERROR
      when :fatal
        @logger.level = Logger::FATAL
      when :info
        @logger.level = Logger::INFO
      when :unknown
        @logger.level = Logger::UNKNOWN
      when :warn
        @logger.level = Logger::WARN
      when :silent
        @logger.instance_variable_set(:@logdev, nil)
      else
        @logger.level = Logger::INFO
      end
    end

    # Find utility path
    #
    # @param [Symbol] name Name of utility
    # @return [Path] Returns the path to the binary of the binary
    def resolve_cmd_name(cmd_name, search_paths=["/bin","/usr/bin"])
      file_found = false

      if cmd_name.kind_of? Symbol
        cmd_path = search_paths.map{ |path| File.join(path, cmd_name.to_s) }.find {|path| File.exists? path } || ""
        if File.exists? cmd_path 
          file_found = true
        end
      else
        if File.exists? cmd_name
          cmd_path = File.expand_path(cmd_name)
          file_found = true
        end
      end

      if file_found == false
        @logger.fatal("Command not found #{cmd_name}")
        raise Exceptions::CommandNotFound , "Command not found: #{cmd_name}"
      end
      
      cmd_path
    end

    # Build string to execute command
    #
    # @return [String] Returns to whole command with parameters and options
    def build_cmd_string
      cmd = ''
      cmd += path
      cmd += options.empty? ? "" : " #{options}"
      cmd += parameter.empty? ? "" : " #{parameter}"

      cmd
    end

    public

    # Output the textual representation of a command
    # public alias for build_cmd_string
    #
    # @return [String] command in text form
    def to_txt 
      build_cmd_string
    end

    # Run the program
    #
    def run
      Dir.chdir(@working_directory) do
        _stdout = ''
        _stderr = ''

        status = POpen4::popen4(build_cmd_string) do |stdout, stderr, stdin, pid|
          _stdout = stdout.read.strip
          _stderr = stderr.read.strip
        end

        error_in_stdout_found = error_in_string_found?(error_keywords,_stdout)
        @result = run_successful?( status.success? ,  error_in_stdout_found ) 

        unless log_file.blank?
          begin
            content_of_log_file = read_log_file(File.open(log_file, "r"))
          rescue Errno::ENOENT
            @logger.warn "Logfile #{log_file} not found!"
          rescue Exception => e
            @logger.fatal "An error happen while reading log_file #{log_file}!"
          end
        end

        if @result == false
          msg = message(
            @result, 
            help_output(
              { 
                :error_in_exec => not(status.success?), 
                :error_in_stdout => error_in_stdout_found 
              }, {
                :stdout => StringIO.new(_stdout),
                :stderr => StringIO.new(_stderr),
                :log_file => content_of_log_file
              }
            )
          )
        else
          msg =  message(@result)
        end

        @logger.info "#{@name.to_s}: #{msg}"
      end

      @result
    end

    # Read the content of the log_file
    #
    # @param [Path] file path to log_file
    # @param [Integer] num_of_lines the number of lines which should be read -- e.g. 30 lines = -30
    def read_log_file(file, num_of_lines=-30)
      content = StringIO.new
      content << file.readlines[num_of_lines..-1].join("")

      content
    end

    # Decide if a program run was successful
    #
    # @return [Boolean] Returns the decision
    def run_successful?(success,error_in_stdout)
      if success == false or error_in_stdout == true 
        return false
      else 
        return true 
      end
    end

    # Decide which output to return to the user
    # to help him with debugging
    #
    # @return [Array] Returns lines of log/stdout/stderr
    def help_output(error_indicators={},output={})
      error_in_exec = error_indicators[:error_in_exec]
      error_in_stdout = error_indicators[:error_in_stdout]

      log_file = output[:log_file].string
      stdout = output[:stdout].string
      stderr = output[:stderr].string

      result = []

      if error_in_exec == true
        result << '================== LOGFILE ================== '
        result << log_file if log_file.empty? == false 
        result << '================== STDOUT ================== '
        result << stdout if stdout.empty? == false
        result << '================== STDERR ================== '
        result << stderr if stderr.empty? == false
      elsif error_in_stdout == true
        result << '================== STDOUT ================== '
        result << stdout 
      end

      result
    end

    # Find error in stdout
    # 
    # @return [Boolean] Returns true if it finds an error
    def error_in_string_found? (keywords=[], string )
      return false if keywords.empty? or not keywords.is_a? Array 
      return false if string.nil? or not string.is_a? String

      error_found = false
      keywords.each do |word|
        if string.include? word
          error_found = true
          break
        end
      end

      error_found
    end

    # Generate the message which is return to the user
    # 
    # @param [Boolean] run_successful true if a positive message should be returned
    # @param [Array] msg Message which should be returned
    def message(run_successful, *msg)

      message = []
      if run_successful
        message << 'OK'.green.bold
      else
        message << 'FAILED'.red.bold
        message.concat msg.flatten
      end

      message.join("\n")
    end

    # Constructur to initiate a new command and run it later
    #
    # @see #initialize
    def Command.execute(name,opts={})
      command = new(name,opts)
      command.run

      command
    end

  end
end
