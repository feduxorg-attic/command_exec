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
    #
    # @return [String] command in text form
    def to_s
      cmd = ''
      cmd += @path
      cmd += @options.blank? ? "" : " #{@options}"
      cmd += @parameter.blank? ? "" : " #{@parameter}"

      @logger.debug cmd

      cmd
    end

    # Run the program
    #
    def run

      process = Process.new(:logger => @logger)
      process.log_file=@log_file

      check_path

      Dir.chdir(@working_directory) do
        status = POpen4::popen4(to_s) do |stdout, stderr, stdin, pid|
          process.stdout = stdout.clone
          process.stderr = stderr.clone
        end
        #process.return_code = status.exitstatus
        @logger.debug "Command exited with #{process.return_code}"

        error_in_stdout_found = error_in_string_found?(error_keywords,process.stdout.read.strip)
        @logger.debug "Errors found in stdout" if error_in_stdout_found

        @result = run_successful?( status.success? ,  error_in_stdout_found ) 
        @logger.debug "Result of command run #{@result}"

        if @result == false
          msg = message(
            @result, 
            help_output(
                :stdout => process.stdout,
                :stderr => process.stderr,
                :log_file => process.log_file,
            )
          )
        else
          msg =  message(@result)
        end

        @logger.info "#{@name.to_s}: #{msg}"
      end

      @result
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
    def help_output(h={})
      handles = {
        log_file: StringIO.new,
        stdout: StringIO.new,
        stderr: StringIO.new
      }.merge h

      result = []
      { log_file:  { 
          io_handle: handles[:log_file],
          header: '================== LOGFILE ==================',
          number_of_lines: 30
        },
        stdout: {
          io_handle: handles[:stdout],
          header: '================== STDOUT  ==================',
          number_of_lines: nil
        },
        stderr: {
          io_handle: handles[:stderr],
          header: '================== STDERR  ==================',
          number_of_lines: nil
        }
      }.each do |io,options|
        tmp = options[:io_handle].readlines(options[:number_of_lines])

        if tmp.size > 0
          result << options[:header]
          result += tmp
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
    def message(run_successful, *output)

      msg = []
      if run_successful
        msg << 'OK'.green.bold
      else
        msg << 'FAILED'.red.bold
        msg += output.flatten
      end

      msg.join("\n")
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
