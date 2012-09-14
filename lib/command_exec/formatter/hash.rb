#encoding: utf-8

module CommandExec
  module Formatter
    class Hash

      attr_reader :output
      attr_writer :logger

    public

      def initialize(options={})
        @options = {
          logger: Logger.new($stdout),
        }.deep_merge options

        @logger = @options[:logger]

        @log_file = []
        @return_code = []
        @stderr = []
        @stdout = []
        @status = []
        @reason_for_failure = []
      end

      def log_file(*content)
        @log_file += content.flatten
      end

      def return_code(*content)
        @return_code += content.flatten
      end

      def stdout(*content)
        @stdout += content.flatten
      end

      def stderr(*content)
        @stderr += content.flatten
      end

      def reason_for_failure(*content)
        @reason_for_failure += content.flatten
      end

      def status(value)
        case value.to_s
        when 'success'
          @status[0] = 'OK'
        when 'failed'
          @status[0] = 'FAILED'
        else
          @status[0] = 'FAILED'
        end

        @status
      end

    private

      def prepare_output(fields=[])
        out = {}

        avail_fields = {
          :status => @status,
          :return_code => @return_code,
          :stderr => @stderr,
          :stdout => @stdout,
          :log_file => @log_file,
          :reason_for_failure => @reason_for_failure,
        }
        fields = [:status,:return_code,:stderr,:stdout,:log_file,:reason_for_failure] if fields.blank?

        fields.each do |f|
          out[f] = avail_fields[f] if avail_fields.has_key?(f)
        end

        out
      end

    public

      def output(*fields)
        prepare_output(fields.flatten)
      end
    end
  end
end
