module CommandExec
  class Process
    attr_accessor :executable
    attr_reader :status, :log_file, :stdout, :stderr, :reason_for_failure, :return_code

    def initialize(options={})
      @options = {
        logger: Logger.new($stderr),
        stderr: [],
        stdout: [],
        output: [],
        return_code: nil,
        reason_for_failure: [],
        status: :success,
      }.merge options

      @logger = @options[:logger]

      @stderr = @options[:stderr]
      @stdout = @options[:stdout]
      @status = @options[:status]
      @reason_for_failure = @options[:reason_for_failure]
      @return_code = @options[:return_code]

      @output = @options[:output]
    end

    def log_file=(filename=nil)
        if filename.blank?
          file = StringIO.new 
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

      @log_file = file.readlines
    end

    def stdout=(*content)
      @stdout += content.flatten
    end

    def stderr=(*content)
      @stderr += content.flatten
    end

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

    def reason_for_failure=(*content)
        @reason_for_failure += content.flatten
    end

    def return_code=(value)
      @return_code = value
    end

    def to_a(*fields, formatter)
      formatter=Formatter::PlainText.new if formatter.nil?

      formatter.status(@status)
      formatter.return_code(@return_code)
      formatter.stderr(@stderr)
      formatter.stdout(@stdout)
      formatter.log_file(@log_file)
      formatter.reason_for_failure(@reason_for_failure)

      formatter.output(fields.flatten)
    end

    def to_h(*fields)

      fields = {
        status: @status,
        return_code: @return_code,
        stderr: @stderr,
        stdout: @stdout,
        log_file: @log_file,
        reason_for_failure: @reason_for_failure,
      } if fields.nil?

      hash = {}
      fields.flatten.each { |f,v| hash[f.to_sym] }

      hash
    end

    def to_s(*fields,formatter)
      formatter=Formatter::PlainText.new if formatter.nil?
      to_a(fields.flatten, formatter).join("\n")
    end

    def to_xml

    end

    def to_json(*fields)
      JSON.generate self.to_h(fields.flatten)
    end

    def to_yml

    end
  end
end

