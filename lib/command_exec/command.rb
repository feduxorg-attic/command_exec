# encoding: utf-8

# Classes concerning command execution
module CommandExec
  # Run commands
  class Command

    attr_accessor :log_file, :options , :parameter
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
        :error_detection_on => [:return_code],
        :error_indicators => {
          :allowed_return_code => [0],
          :forbidden_return_code => [],
          :allowed_word_in_stderr => [],
          :forbidden_word_in_stderr => [],
        },
        :on_error_do => :return_process_information,
        :working_directory => Dir.pwd,
        :log_file => '',
        :log_level => :info,
        :search_paths => ENV['PATH'].split(':'),
      }.deep_merge opts

      @logger = @opts[:logger] 
      configure_logging 

      @logger.debug @opts

      @options = @opts[:options]
      @path = resolve_path @name, @opts[:search_paths]
      @parameter = @opts[:parameter]
      @log_file = @opts[:log_file]

      *@error_detection_on = @opts[:error_detection_on]
      @error_indicators = @opts[:error_indicators]
      @on_error_do = @opts[:on_error_do]

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
      process.log_file = @log_file

      check_path

      Dir.chdir(@working_directory) do
        status = POpen4::popen4(to_s) do |stdout, stderr, stdin, pid|
          process.stdout = stdout.readlines
          process.stderr = stderr.readlines
        end

        process.return_code = status.exitstatus

        if @error_detection_on.include?(:return_code)
          unless @error_indicators[:allowed_return_code].include? process.return_code
            process.status = :failed 
          end
        end

        if @error_detection_on.include?(:stderr) and not process.status == :failed
          if error_occured?( @error_indicators[:forbidden_word_in_stderr], process.stderr)
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
    def error_occured?(*needles, haystacks )
      error_found = false
      needles = needles.flatten
      *haystacks = haystacks

      return false if needles.blank? 
      return false if haystacks.blank?

      needles.each do |n|
        haystacks.each do |h|
          if h.include? n
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
