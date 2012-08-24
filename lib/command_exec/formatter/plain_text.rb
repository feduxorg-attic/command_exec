module CommandExec
  module Formatter
    class PlainText

      attr_reader :output
      attr_writer :logger

      def initialize(options={})
        @options = {
          headers: {
            names: {
              status:      'STATUS',
              return_code: 'RETURN CODE',
              log_file:    'LOG FILE',
              stderr:      'STDERR',
              stdout:      'STDOUT',
              reason_for_failure: 'REASON FOR FAILURE',
            },
            prefix: '=' * 5,
            suffix: '=' * 5,
            halign: :center,
            show: true,
          },
          color_set: :success,
        }.deep_merge options

        @headers_options = @options[:headers]
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

      def max_header_length
        @max_header_length ||= @headers_options[:names].values.inject(0) { |max_length, name|  max_length < name.length ? name.length : max_length }
      end

      def halign(name, max_length, orientation)
        case orientation
        when :center
          halign_center(name,max_length)
        else
          halign_center(name,max_length)
        end
      end

      def halign_center(name, max_length)
        num_whitespace = ( max_length - name.length ) / 2.0
        name = ' ' * num_whitespace.floor + name + ' ' * num_whitespace.ceil
      end

      def format_header(header,options={})
       "#{options[:prefix]} #{halign(options[:names][header], max_header_length, :center)} #{options[:suffix]}"
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
          out << format_header(var,@headers_options) if @headers_options[:show] = true and avail_order.has_key?(var)
          out += avail_order[var] if avail_order.has_key?(var)
        end

        out.flatten
      end
    end
  end
end
