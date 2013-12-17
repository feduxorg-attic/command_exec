# encoding: utf-8
# Main
module CommandExec
  # The class used to save the data about
  # the executed command
  class Process
    include FieldHelper
    # @!attribute [rw] executable
    #   Set/Get the executable of the command
    #
    # @!attribute [rw] return_code
    #   Set/Get the exit status of the command
    #
    # @!attribute [rw] start_time
    #   Set/Get the start time of the command execution
    #
    # @!attribute [rw] end_time
    #   Set/Get the end time of the command execution
    attr_accessor :executable, :return_code, :start_time, :end_time

    # @!attribute [r] status
    #   Get the status of the command
    #
    # @!attribute [r] stdout
    #   Get stdout of the command
    #
    # @!attribute [r] stderr
    #   Get stderr of the command
    #
    # @!attribute [r] reason_for_failure
    #   Get the reason why `command_exec` thinks a command failed
    #
    # @!attribute [r] return_code
    #   Get the exit code of the command
    #
    # @!attribute [r] pid
    #   Get the pid of the command
    attr_reader :status, :log_file, :stdout, :stderr, :reason_for_failure, :pid

    # Create a process object
    #
    # @param [Hash] options
    #   options for the process
    #
    # @option options [Logger] lib_logger
    #   The logger which is used to output information generated by the
    #   library. The logger which is provided needs to be compatible with api
    #   of the Ruby `Logger`-class.
    #
    # @option options [Array] stderr
    #   content of stderr of the process
    #
    # @option options [Array] stdout
    #   content of stdout of the process
    #
    # @option options [Array] log_file
    #   content of the log file of the process
    #
    # @option options [Number,String] pid
    #   the pid of the process
    #
    # @option options [Number,String] return_code
    #   the exit status of the process
    #
    # @option options [Array] reason_for_failure
    #   the reason for failure
    #
    # @option options [Symbol] status
    #   execution was successful, failed
    def initialize(options = {})
      @options = {
        lib_logger: Logger.new($stderr),
        stderr: [],
        stdout: [],
        log_file: [],
        pid: nil,
        return_code: nil,
        reason_for_failure: [],
        status: :success,
        executable: nil,
      }.merge options

      @logger = @options[:lib_logger]

      @stderr = @options[:stderr]
      @stdout = @options[:stdout]
      @status = @options[:status]
      @log_file = @options[:log_file]
      @pid = @options[:pid]
      @reason_for_failure = @options[:reason_for_failure]
      @return_code = @options[:return_code]
      @executable = @options[:executable]

      @start_time = nil
      @end_time = nil
    end

    # Set the name of the log file
    #
    # @param [String] filename
    #   the name of the log file
    def log_file=(filename = nil)
      if filename.blank?
        file = StringIO.new
        @logger.debug 'No file name for log file given. Using empty String'
      else
        begin
          file = File.open(filename)
          @logger.debug "read logfile \"#{file}\" "
        rescue Errno::ENOENT
          file = StringIO.new
          @logger.warn "Logfile #{filename} not found!"
        rescue Exception => e
          file = StringIO.new
          @logger.warn "An error happen while reading log_file \"#{filename}\": #{e.message}"
        end
      end

      @log_file = file.readlines.map(&:chomp)
    end

    # Set the pid of the process
    #
    # @param [Number,String] value
    def pid=(value)
      @pid = value.to_s
    end

    # Set the value of stdout
    #
    # @param [Array, String] content
    #   the content of stdout
    def stdout=(*content)
      @stdout += content.flatten
    end

    # Set the value of stderr
    #
    # @param [Array, String] content
    #   the content of stderr
    def stderr=(*content)
      @stderr += content.flatten
    end

    # Set the status of command execution
    #
    # @param [Array, String] value
    #   the status
    def status=(value)
      case value.to_s
      when 'success'
        @status = :success
      when 'failed'
        @status = :failed
      else
        @status = :failed
      end

      @status
    end

    # Why the execution failed
    #
    # @param [String] content
    #   the reason for failure. When you run it mulitple times, the string is
    #   added at the end.
    def reason_for_failure=(content)
      @reason_for_failure << content.to_s
    end

    def run_time
      end_time - start_time
    end

    private

    # Generate formatted output
    #
    # @param [Symbol,Array of Symbols] fields
    #   the field which should be part of the output
    #
    # @param [Formatter] formatter
    #   the formatter which is used to format the output
    def output(*fields, formatter)
      fields.flatten.each do |f|
        formatter.public_send(f, available_fields[f])
      end

      formatter.output(fields.flatten)
    end

    public

    # Output process data as array
    #
    # @param [Array of Symbols] fields
    #   the fields which should be outputed
    #
    # @param [Formatter] formatter (Formatter::Array.new)
    #   the formatter which is used the format the output
    def to_a(fields = default_fields, formatter = Formatter::Array.new)
      output(fields, formatter)
    end

    # Output process data as hash
    #
    # @param [Array of Symbols] fields
    #   the fields which should be outputed
    #
    # @param [Formatter] formatter (Formatter::Hash.new)
    #   the formatter which is used the format the output
    def to_h(fields = default_fields, formatter = Formatter::Hash.new)
      output(fields, formatter)
    end

    # Output process data as string
    #
    # @param [Array of Symbols] fields
    #   the fields which should be outputed
    #
    # @param [Formatter] formatter (Formatter::String.new)
    #   the formatter which is used the format the output
    def to_s(fields = default_fields, formatter = Formatter::String.new)
      output(fields, formatter)
    end

    # Output process data as xml
    #
    # @param [Array of Symbols] fields
    #   the fields which should be outputed
    #
    # @param [Formatter] formatter (Formatter::XML.new)
    #   the formatter which is used the format the output
    def to_xml(fields = default_fields, formatter = Formatter::XML.new)
      output(fields, formatter)
    end

    # Output process data as json
    #
    # @param [Array of Symbols] fields
    #   the fields which should be outputed
    #
    # @param [Formatter] formatter (Formatter::JSON.new)
    #   the formatter which is used the format the output
    def to_json(fields = default_fields, formatter = Formatter::JSON.new)
      output(fields, formatter)
    end

    # Output process data as yaml
    #
    # @param [Array of Symbols] fields
    #   the fields which should be outputed
    #
    # @param [Formatter] formatter (Formatter::YAML.new)
    #   the formatter which is used the format the output
    def to_yaml(fields = default_fields, formatter = Formatter::YAML.new)
      output(fields, formatter)
    end
  end
end
