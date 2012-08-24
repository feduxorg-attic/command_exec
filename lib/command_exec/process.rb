module CommandExec
  class Process
    attr_accessor :return_code, :executable, :stdout, :stderr, :output, :reason_for_failure
    attr_reader :status

    def initialize(options={})
      @options = {
        :logger => Logger.new($stderr),
        :stderr => [],
        :stdout => [],
        :output => [],
        :status => :success,
      }.merge options

      @logger = @options[:logger]
      @stderr = @options[:stderr]
      @stout = @options[:stdout]
      @status = @options[:status]
      @output = @options[:output]
      @reason_for_failure = :none
    end

    def log_file(filename=nil)
      if @log_file
        return @log_file
      else
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
            @logger.warn "An error happen while reading log_file #{filename}: #{e.message}"
          end
        end

        return @log_file = file.readlines
      end
    end

    def status=(val)
      @status = val unless @status == :failed
    end

  end
end

