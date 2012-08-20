module CommandExec
  class Process
    attr_accessor :return_code, :executable, :stdout, :stderr
    attr_reader :log_file, :status

    def initialize(options={})
      @options = {
        :logger => Logger.new($stderr)
      }.merge options

      @logger = @options[:logger]
    end

    def log_file=(filename)
      if filename.blank?
        @log_file = StringIO.new 
      else
        begin
          @log_file = File.open(@filename)
          @logger.debug "read logfile \"#{file}\" "
        rescue Errno::ENOENT
          @log_file = StringIO.new
          @logger.warn "Logfile #{@filename} not found!"
        rescue Exception => e
          @log_file = StringIO.new
          @logger.warn "An error happen while reading log_file #{@filename}: #{e.message}"
        end
      end

      @log_file
    end

    def status=(val)
      @status = :failed if val == :failed
    end

  end
end

