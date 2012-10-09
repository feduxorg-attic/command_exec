# encoding: utf-8

#Main
module CommandExec
  #Formatting output
  module Formatter
    #Style array
    class Array

      # @!attribute [r] output
      #   return the formatted output
      attr_reader :output
      # @!attribute [w] logger
      #   set the logger after object creation
      attr_writer :logger

      # Create new array formatter
      # 
      # @param [Hash] options
      #   Options for formatter
      #
      # @option options [Hash] :headers
      #   It is used to configure how the headers will be formatted
      #
      #   There are several sub-options:
      #
      #   * :names  [Hash]: What should be output as name for the header
      #     * :status [String]: 'STATUS'
      #     * :return_code [String]: 'RETURN CODE'
      #     * :log_file [String]: 'LOG FILE'
      #     * :stderr [String]: 'STDERR'
      #     * :stdout [String]: 'STDOUT'
      #     * :pid [String]: 'PID'
      #     * :reason\_for\_failure [String]: 'REASON FOR FAILURE'
      #   * :prefix [String]: What is placed before the header ('=' * 5)
      #   * :suffix [String]: What is placed after the header ('=' * 5)
      #   * :halign [Symbol]: How to align the header: :center [default], :left, :right
      #   * :show (Boolean): Should the header be shown (true)
      #
      # @option options [Symbol] :logger
      #   Logger to output information. Needs to have the same interface like
      #   the ruby `Logger`-class.
      #   
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
          logger: Logger.new($stdout),
        }.deep_merge options

        @headers_options = @options[:headers]
        @logger = @options[:logger]

        @log_file = []
        @return_code = []
        @stderr = []
        @stdout = []
        @status = []
        @pid = []
        @reason_for_failure = []
      end

      # Set the content of the log file
      #
      # @param content [Array,String]
      #   The content of log file
      def log_file(*content)
        @log_file += content.flatten
      end

      # Set the return code of the command
      #
      # @param value [Array,String]
      #   Set the return code(s) of the command. 
      def return_code(value)
        @return_code[0] = value.to_s

        @return_code
      end

      # Set the content of stdout
      #
      # @param content [Array,String]
      #   The content of stdout
      def stdout(*content)
        @stdout += content.flatten
      end

      # Set the content of stderr
      #
      # @param content [Array,String]
      #   The content of stderr
      def stderr(*content)
        @stderr += content.flatten
      end

      def pid(value)
        @pid[0] = value.to_s

        @pid
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
