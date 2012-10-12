# encoding: utf-8

#Main
module CommandExec
  #Formatting output
  module Formatter
    #Style array
    class Array

      include FieldHelper

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
            prefix: '=' * 5,
            suffix: '=' * 5,
            halign: :center,
            show: true,
          },
          logger: Logger.new($stdout),
        }.deep_merge(header_names.deep_merge(options))

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
      #
      # @return [Array] the content of the log file
      def log_file(*content)
        @log_file += content.flatten
      end

      # Set the return code of the command
      #
      # @param value [Number,String]
      #   Set the return code(s) of the command. 
      #
      # @return [Array] the return code
      def return_code(value)
        @return_code[0] = value.to_s

        @return_code
      end

      # Set the content of stdout
      #
      # @param content [Array,String]
      #   The content of stdout
      #
      # @return [Array]
      def stdout(*content)
        @stdout += content.flatten
      end

      # Set the content of stderr
      #
      # @param content [Array,String]
      #   The content of stderr
      #
      # @return [Array]
      def stderr(*content)
        @stderr += content.flatten
      end

      # Set the pid of the command
      #
      # @param value [Number,String]
      #   Set the pid of the command. 
      #
      # @return [Array]
      def pid(value)
        @pid[0] = value.to_s

        @pid
      end

      # Set the reason for failure
      #
      # @param content [Array, String] 
      #   Set the reason for failure.
      #
      # @return [Array]
      def reason_for_failure(*content)
        @reason_for_failure += content.flatten
      end

      # Set the status of the command
      #
      # param [String,Symbol] value
      #   Set the status of the command based on input.
      #
      # @return [Array] 
      #   the formatted status. It returns `OK` in bold and green if status is
      #   `:success` and `FAILED` in bold and red if status is `:failed`.
      #
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

      # Get the maximum length over all headers
      #
      # @return [Number] the maxium header length
      def max_header_length
        @max_header_length ||= @headers_options[:names].values.inject(0) { |max_length, name|  max_length < name.length ? name.length : max_length }
      end

      # Align header names
      #
      # @param [String] name
      #   the name which should be aligned
      # 
      # @param max_length [Number]
      #   the maximum length which is used to align the name
      #
      # @param orientation [Symbol]
      #   how to align the header name
      #
      # @return [String] the aligned header name
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

      # Format header but only if given header is defined.
      #
      # @param [Symbol] header
      #   the name of the header. It has to be defined in opts[:names]
      #
      # @param [Hash] options
      #   used to change format options like `prefix`, `suffix` etc. after the
      #   creation of the `Formatter::Array`-object. Those options defined at the
      #   creation of the `Formatter`-object are default and can be overwritten 
      #   using this `Hash`.
      #
      # @return [String] the formatted header
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

      # Build the data structure for output
      #
      # @param [Array] fields
      #   which fields should be outputted
      #
      # @return [Array] 
      #   the formatted output
      def prepare_output(fields=[])
        out = []
        fields = fields.flatten

        fields = default_fields if fields.blank?

        fields.each do |var|
          out << format_header(var,@headers_options) if @headers_options[:show] = true and available_fields.has_key?(var)
          out += available_fields[var] if available_fields.has_key?(var)
        end

        out
      end

      public

      # Output the prepared output
      #
      # @param [Array,Symbol) fields
      #   the fields which should be outputted
      #
      # @return [Array] 
      #   the formatted output
      def output(*fields)
        prepare_output(fields.flatten)
      end
    end
  end
end
