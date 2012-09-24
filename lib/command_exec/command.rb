# encoding: utf-8

# Classes concerning command execution
module CommandExec
  # Run commands
  class Command

    attr_accessor :cmd_log_file, :options , :parameter
    attr_reader :result, :path, :working_directory

    # Create a new command to execute
    #
    # @param [Symbol] name 
    #   name of command
    #
    # @param [optional,Hash] opts 
    #   options for the command
    #
    # @option opts [String] :options 
    #   options for binary
    #
    # @option opts [String] :parameter parameter for binary
    # @option opts [String] :parameter parameter for binary
    # @option opts [optional,Hash] :error_indicators indicating an error while execution of command 
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
        :cmd_log_file => '',
        :error_detection_on => [:return_code],
        :error_indicators => {
          :allowed_return_code => [0],
          :forbidden_return_code => [],
          #
          :allowed_words_in_stderr => [],
          :forbidden_words_in_stderr => [],
          #
          :allowed_words_in_stdout => [],
          :forbidden_words_in_stdout => [],
          #
          :allowed_words_in_log_file => [],
          :forbidden_words_in_log_file => [],
        },
        :on_error_do => :return_process_information,
        :working_directory => Dir.pwd,
        :log_file => '',
        :run_via => :open3,
        :log_level => :info,
        :search_paths => ENV['PATH'].split(':'),
      }.deep_merge opts

      @logger = @opts[:logger] 
      configure_logging 

      @logger.debug @opts

      @options = @opts[:options]
      @path = resolve_path @name, @opts[:search_paths]
      @parameter = @opts[:parameter]
      @cmd_log_file = @opts[:cmd_log_file]

      *@error_detection_on = @opts[:error_detection_on]
      @error_indicators = @opts[:error_indicators]
      @on_error_do = @opts[:on_error_do]

      @run_via = @opts[:run_via]

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
      process = CommandExec::Process.new(:logger => @logger)
      process.log_file = @cmd_log_file if @cmd_log_file
      process.status = :success

      check_path

      case @run_via
      when :open3
        Open3::popen3(to_s, :chdir => @working_directory) do |stdin, stdout, stderr, wait_thr|
          process.stdout = stdout.readlines
          process.stderr = stderr.readlines
          process.pid = wait_thr.pid
          process.return_code = wait_thr.value.exitstatus
        end
      when :system
        Dir.chdir(@working_directory) do
          system(to_s)
          process.stdout = []
          process.stderr = []
          process.pid = $?.pid
          process.return_code = $?.exitstatus
        end
      else
        Open3::popen3(to_s, :chdir => @working_directory) do |stdin, stdout, stderr, wait_thr|
          process.stdout = stdout.readlines
          process.stderr = stderr.readlines
          process.pid = wait_thr.pid
          process.return_code = wait_thr.value.exitstatus
        end
      end

        if @error_detection_on.include?(:return_code)
          if not @error_indicators[:allowed_return_code].include? process.return_code or 
                 @error_indicators[:forbidden_return_code].include? process.return_code

            @logger.debug "Error detection on return code found an error"
            process.status = :failed 
            process.reason_for_failure = :return_code
          end
        end

        if @error_detection_on.include?(:stderr) and not process.status == :failed
          if error_occured?( @error_indicators[:forbidden_words_in_stderr], @error_indicators[:allowed_words_in_stderr], process.stderr)
            @logger.debug "Error detection on stderr found an error"
            process.status = :failed 
          end
        end

        if @error_detection_on.include?(:stdout) and not process.status == :failed
          if error_occured?( @error_indicators[:forbidden_words_in_stdout], @error_indicators[:allowed_words_in_stdout], process.stdout)
            @logger.debug "Error detection on stdout found an error"
            process.status = :failed 
          end
        end

        if @error_detection_on.include?(:log_file) and not process.status == :failed
          if error_occured?( @error_indicators[:forbidden_words_in_log_file], @error_indicators[:allowed_words_in_log_file], process.log_file)
            @logger.debug "Error detection on log file found an error"
            process.status = :failed 
          end
        end

        @logger.debug "Result of command run #{process.status}"
      end

      @result = process
    end

    # Find error in stdout
    # 
    # @return [Boolean] Returns true if it finds an error
    def error_occured?(forbidden_word, exception, data )
      error_found = false
      *forbidden_word = forbidden_word
      *exception = exception
      *data = data

      return false if forbidden_word.blank?
      return false if data.blank?

      forbidden_word.each do |word|
        data.each do |line|
          line.strip!

          #line includes word -> error
          #exception does not include line/substring of line -> error, if
          #  includes line/substring of line -> no error
          if line.include? word and exception.find{ |e| line[e] }.blank?
            error_found = true
            break
          end
        end
      end

      error_found
    end

    # Run a command 
    #
    # @see #initialize
    def self.execute(name,opts={})
      command = new(name,opts)
      command.run

      command
    end
  end
end
