#encoding: utf-8

module CommandExec
  module Formatter
    class Hash < Base

      attr_reader :output
      attr_writer :logger

      public

      def initialize(options={})
        super

        @options = {
          logger: Logger.new($stdout),
        }.deep_merge options

        @logger = @options[:logger]
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

      def output(*fields)
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

        fields.flatten.each do |f|
          out[f] = avail_fields[f] if avail_fields.has_key?(f)
        end

        out
      end
    end
  end
end
