module CommandExec
  class Process
    attr_accessor :return_code, :executable, :stdout, :stderr
    attr_reader :status

    def initialize(options={})
      @options = {
        :logger => Logger.new($stderr),
        :stderr => [],
        :stdout => [],
      }.merge options

      @logger = @options[:logger]
      @stderr = @options[:stderr]
      @stout = @options[:stdout]
    end

    def log_file(filename)
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
      @status = :failed if val == :failed
    end

  end
end

