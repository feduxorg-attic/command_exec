module CommandExec
  module Formatter
    class PlainText

      attr_reader :output
      attr_writer :logger

      def initialize(options={})
        @options = {
          header: {
            status:      '======= STATUS      =======',
            return_code: '======= RETURN CODE =======',
            log_file:    '======= LOG FILE    =======',
            stderr:      '======= STDERR      =======',
            stdout:      '======= STDOUT      =======',
          color_set: :success,
          }
        }.deep_merge options

        @header = @options[:header]
        @color_set = @options[:success]

        @log_file = []
        @return_code = []
        @stderr = []
        @stdout = []
        @status = []
        @reason_for_failure = []

        @logger = Logger.new($stdout)
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

      def status(value)
        if value.to_s == 'success'
          @status[1] = 'OK'.green.bold
        else
          @status[1] = 'FAILED'.green.bold
        end

        @status
      end

      def reason_for_failure(value)
        @reason_for_failure << value.to_s
      end

      def output(*order)
        out = []

        avail_order = {
          :status => @status,
          :return_code => @return_code,
          :stderr => @stderr,
          :stdout => @stdout,
          :log_file => @log_file,
          :reason_for_failure => @reason_for_failure,
        }
        order = [:status,:return_code,:stderr,:stdout,:log_file,:reason_for_failure] if order.blank?

        order.flatten.each do |var|
          out += avail_order[var]
        end

        out.flatten
      end
    end
  end
end
