# encoding: utf-8

# Classes concerning command execution
module CommandExec
  # Run commands
  class Command

    attr_accessor :logfile, :options , :parameter, :error_keywords
    attr_reader :result, :path, :working_directory

    # Create a new command to execute
    #
    # @param [Symbol] name name of command
    # @param [optional,Hash] opts options for the command
    # @option opts [String] :options options for binary
    # @option opts [String] :parameter parameter for binary
    # @option opts [String] :error_keywords keyword indicating an error on stdout
    # @option opts [String] :working_directory working directory where the process should run in
    # @option opts [String] :logfile file path to log file of process
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
        :logfile => '',
        :log_level => :info,
        :search_paths => ENV['PATH'].split(':'),
      }.update opts


      @logger = @opts[:logger] 
      @options = @opts[:options]
      @parameter = @opts[:parameter]
      @path = resolve_cmd_name(name, @opts[:search_paths])
      @error_keywords = @opts[:error_keywords]
      @logfile = @opts[:logfile]

      configure_logging

      @working_directory = @opts[:working_directory] 
      Dir.chdir(working_directory)

    end

    private

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
        log_level = Logger::INFO
      end
    end

    # Find utility path
    #
    # @param [Symbol] name Name of utility
    # @return [Path] Returns the path to the binary of the binary
    def resolve_cmd_name(cmd_name, search_paths=["/bin","/usr/bin"])
      cmd_name = cmd_name.to_s
      file_found = false

      if (cmd_name =~ /\A\//) or (cmd_name.scan(/\A(?:\w+|\.)\/\w+/).count > 0)
        if File.exists? cmd_name 
          cmd_path = File.expand_path(cmd_name)
          file_found = true
        end
      else
        cmd_path = search_paths.map{ |path| File.join(path, cmd_name) }.find {|path| File.exists? path } || ""
        if File.exists? cmd_path 
          file_found = true
        end
      end

      if file_found == false
        @logger.fatal("Command not found #{cmd_name}")
        raise Exceptions::CommandNotFound 
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

      _stdout = ''
      _stderr = ''

      status = POpen4::popen4(build_cmd_string) do |stdout, stderr, stdin, pid|
        _stdout = stdout.read.strip
        _stderr = stderr.read.strip
      end


      error_in_stdout_found = error_in_string_found?(error_keywords,_stdout)
      @result = run_successful?( status.success? ,  error_in_stdout_found ) 

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
              :logfile => read_logfile(logfile),
            }
          )
        )
      else
        msg =  message(@result)
      end

      @logger.info "#{@name.to_s}: #{msg}"

      @result
    end

    # Read the content of the logfile
    #
    # @param [Path] file path to logfile
    # @param [Integer] num_of_lines the number of lines which should be read -- e.g. 30 lines = -30
    def read_logfile(file, num_of_lines=-30)
      content = StringIO.new

      unless file.empty? 
        begin
          content << File.readlines(logfile)[num_of_lines..-1].join("")
        rescue Errno::ENOENT
          @logger.warn "Warning: logfile not found!"
        end
      end

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

      logfile = output[:logfile].string
      stdout = output[:stdout].string
      stderr = output[:stderr].string

      result = []

      if error_in_exec == true
        result << '================== LOGFILE ================== '
        result << logfile if logfile.empty? == false 
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
