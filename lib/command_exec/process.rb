module CommandExec
  class Process
    attr_accessor :status, :return_code, :executable, :stdout, :stderr
    attr_reader :log_file

    def initialize(options={})
      @options = {
        :logger => Logger.new($stderr)
      }.merge options

      @logger = @options[:logger]
    end

    def log_file=(filename)
      return StringIO.new if filename.blank?

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

      @log_file
    end

    # Read the content of the log_file
    #
    # @param [Path] filename path to log_file
    # @return [IO] handle for io
  end
end

