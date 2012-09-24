# encoding: utf-8

module CommandExec
  module Formatter
    class Array

      attr_reader :output
      attr_writer :logger

    public

      def initialize(options={})
        @options = {
          headers: {
            names: {
              status:      'STATUS',
              return_code: 'RETURN CODE',
              log_file:    'LOG FILE',
              stderr:      'STDERR',
              stdout:      'STDOUT',
              pid:         'PID',
              reason_for_failure: 'REASON FOR FAILURE',
            },
            prefix: '=' * 5,
            suffix: '=' * 5,
            halign: :center,
            show: true,
          },
          color_set: :success,
          logger: Logger.new($stdout),
        }.deep_merge options

        @headers_options = @options[:headers]
        @color_set = @options[:success]
        @logger = @options[:logger]

        @log_file = []
        @return_code = []
        @stderr = []
        @stdout = []
        @status = []
        @pid = []
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

      def pid(value)
        @pid[0] = value.to_s
      end

      def reason_for_failure(*content)
        @reason_for_failure += content.flatten
      end


      def status(value)
        case value.to_s
        when 'success'
          @status[0] = 'OK'.green.bold
        when 'failed'
          @status[0] = 'FAILED'.green.bold
        else
          @status[0] = 'FAILED'.green.bold
        end

        @status
      end

    private 

      def max_header_length
        @max_header_length ||= @headers_options[:names].values.inject(0) { |max_length, name|  max_length < name.length ? name.length : max_length }
      end

      def halign(name, max_length, orientation)
        case orientation
        when :center
          name.center(max_length)
        when :left
          name.ljust(max_length)
        when :right
          name.rjust(max_length)
        else
          name.center(max_length)
        end
      end

      def format_header(header,options={})
        opts = @headers_options.deep_merge options

        output=""
        unless opts[:names][header] == ""
          output += "#{opts[:prefix]} " unless opts[:prefix].blank?
          output += halign(opts[:names][header], max_header_length, opts[:halign])
          output += " #{opts[:suffix]}" unless opts[:suffix].blank?
        end

        output
      end

      def prepare_output(fields=[])
        out = []
        fields = fields.flatten

        avail_fields = {
          :status => @status,
          :return_code => @return_code,
          :stderr => @stderr,
          :stdout => @stdout,
          :log_file => @log_file,
          :pid => @pid,
          :reason_for_failure => @reason_for_failure,
        }

        fields = [:status,:return_code,:stderr,:stdout,:log_file,:pid,:reason_for_failure] if fields.blank?

        fields.each do |var|
          out << format_header(var,@headers_options) if @headers_options[:show] = true and avail_fields.has_key?(var)
          out += avail_fields[var] if avail_fields.has_key?(var)
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
