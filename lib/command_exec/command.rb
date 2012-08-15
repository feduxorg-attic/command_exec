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
      configure_logging 

      @logger.debug @opts

      @options = @opts[:options]
      @path = resolve_path @name, @opts[:search_paths]
      @parameter = @opts[:parameter]
      @error_keywords = @opts[:error_keywords]
      @log_file = @opts[:log_file]

      @working_directory = @opts[:working_directory] 
      @result = nil
    end

    private

    # Find path to cmd
    #
    # @param [String] name 
    # Name of command. It accepts :cmd, 'cmd', 'rel_path/cmd' or
    # '/fq_path/to/cmd'. When :cmd is used it searches 'search_paths' for the
    # executable. Whenn 'cmd' is used it looks for cmd in local dir. The same
    # happens when 'rel_path/cmd' is used. A full qualified path
    # '/fq_path/to/cmd' at is used as normal.
    # 
    # @param [Array] search_paths
    # Where to look for executables
    #
    # @return [String] fully qualified path to command
    #
    def resolve_path(name,*search_paths)
      search_paths ||= ['/bin', '/usr/bin']
      search_paths = search_paths.flatten

      if name.kind_of? Symbol
        path = search_paths.map{ |p| File.join(p, name.to_s) }.find {|p| File.exists? p } || ""
      else
        path = File.expand_path(name)
      end

      path
    end
    
    def check_path
      unless exists?
        @logger.fatal("Command '#{@name}' not found.")
        raise Exceptions::CommandNotFound , "Command '#{@name}' not found."
      end

      unless executable?
        @logger.fatal("Command '#{@name}' not executable.")
        raise Exceptions::CommandNotExecutable , "Command '#{@name}' not executable."
      end

      unless file?
        @logger.fatal("Command '#{@name}' not a file.")
        raise Exceptions::CommandIsNotAFile, "Command '#{@name}' not a file."
      end
    end

    def configure_logging
      case @opts[:log_level]
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

      @logger.debug "Logger configured with log level #{@logger.level}"

      nil
    end

    # Build string to execute command
    #
    # @return [String] Returns to whole command with parameters and options
    def build_cmd_string
      cmd = ''
      cmd += path
      cmd += options.empty? ? "" : " #{options}"
      cmd += parameter.empty? ? "" : " #{parameter}"

      @logger.debug cmd

      cmd
    end

    public

    def valid?
      exists? and executable? and file?
    end

    def exists?
      File.exists? @path
    end

    def executable?
      File.executable? @path
    end

    def file?
      File.file? @path
    end

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

      check_path

      Dir.chdir(@working_directory) do
        _stdout = ''
        _stderr = ''

        status = POpen4::popen4(build_cmd_string) do |stdout, stderr, stdin, pid|
          _stdout = stdout.read.strip
          _stderr = stderr.read.strip
        end
        @logger.debug "Command exited with #{status}"

        error_in_stdout_found = error_in_string_found?(error_keywords,_stdout)
        @logger.debug "Errors found in stdout" if error_in_stdout_found

        @result = run_successful?( status.success? ,  error_in_stdout_found ) 
        @logger.debug "Result of command run #{@result}"

        binding.pry

        if @log_file.blank?
          content_of_log_file = StringIO.new
        else
          begin
            content_of_log_file = read_log_file(File.open(@log_file, "r"))
            @logger.debug "Content of logfile \"#{truncate(content_of_log_file)}\" "
          rescue Errno::ENOENT
            @logger.warn "Logfile #{@log_file} not found!"
          rescue Exception => e
            @logger.warn "An error happen while reading log_file #{@log_file}!"
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

      unless output[:log_file].blank?
        log_file = output[:log_file].string
      end
      stdout = output[:stdout].string
      stderr = output[:stderr].string

      result = []

      if error_in_exec == true
        result << '================== LOGFILE ================== '
        if log_file.blank? 
          result << 'nothing'
        else
          result << log_file 
        end

        result << '================== STDOUT ================== '
        if stdout.blank? 
          result << 'nothing'
        else
          result << stdout 
        end

        result << '================== STDERR ================== '
        if stderr.blank? 
          result << 'nothing'
        else
          result << stderr 
        end
      elsif error_in_stdout == true
        result << '================== STDOUT ================== '
        if stdout.blank? 
          result << 'nothing'
        else
          result << stdout 
        end
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
