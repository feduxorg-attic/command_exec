#encoding: utf-8

module CommandExec
  class Process
    attr_accessor :executable 
    attr_reader :status, :log_file, :stdout, :stderr, :reason_for_failure, :return_code, :pid

    def initialize(options={})
      @options = {
        lib_logger: Logger.new($stderr),
        stderr: [],
        stdout: [],
        output: [],
        pid: nil,
        return_code: nil,
        reason_for_failure: [],
        status: :success,
      }.merge options

      @logger = @options[:lib_logger]

      @stderr = @options[:stderr]
      @stdout = @options[:stdout]
      @status = @options[:status]
      @pid = @options[:pid]
      @reason_for_failure = @options[:reason_for_failure]
      @return_code = @options[:return_code]

      @output = @options[:output]
    end

    def log_file=(filename=nil)
        if filename.blank?
          file = StringIO.new 
          @logger.debug "No file name for log file given. Using empty String"
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

    def pid=(value)
      @pid = value.to_s
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

    def reason_for_failure=(content)
      @reason_for_failure << content.to_s
    end

    def return_code=(value)
      @return_code = value
    end

    private 

    def output(*fields,formatter)

      avail_fields = {
        status: @status,
        return_code: @return_code,
        stderr: @stderr,
        stdout: @stdout,
        log_file: @log_file,
        pid: @pid,
        reason_for_failure: @reason_for_failure,
      } 

      fields.flatten.each do |f|
        formatter.public_send(f, avail_fields[f])
      end

      formatter.output(fields.flatten)
    end

    public 

    def to_a(fields=[:status,:return_code,:stderr,:stdout,:log_file,:pid,:reason_for_failure], formatter=Formatter::Array.new)
      output(fields, formatter)
    end

    def to_h(fields=[:status,:return_code,:stderr,:stdout,:log_file,:pid,:reason_for_failure], formatter=Formatter::Hash.new)
      output(fields, formatter)
    end

    def to_s(fields=[:status,:return_code,:stderr,:stdout,:log_file,:pid,:reason_for_failure], formatter=Formatter::String.new)
      output(fields, formatter)
    end

    def to_xml(fields=[:status,:return_code,:stderr,:stdout,:log_file,:pid,:reason_for_failure], formatter=Formatter::XML.new)
      output(fields, formatter)
    end

    def to_json(fields=[:status,:return_code,:stderr,:stdout,:log_file,:pid,:reason_for_failure], formatter=Formatter::JSON.new)
      output(fields, formatter)
    end

    def to_yaml(fields=[:status,:return_code,:stderr,:stdout,:log_file,:pid,:reason_for_failure], formatter=Formatter::YAML.new)
      output(fields, formatter)
    end
  end
end

