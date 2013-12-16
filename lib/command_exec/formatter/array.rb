# encoding: utf-8
# Main
module CommandExec
  # Formatting output
  module Formatter
    # Style array
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
      #   * :names  [Hash]: What should be output as name for the header (filled via deep_merge and FieldHelper-Module)
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
            names: {}, 
            prefix: '=' * 5,
            suffix: '=' * 5,
            halign: :center,
            show: true,
          },
          logger: Logger.new($stdout),
        }.deep_merge(header_names.deep_merge(options))

        @headers_options = @options[:headers]
        @logger = @options[:logger]

        super()
      end

      def status(value)
        prepare_status(value, color: true)
      end

      private 

      # Get the maximum length over all headers
      #
      # @return [Number] the maxium header length
      def max_header_length
        @max_header_length ||= @headers_options[:names].values.reduce(0) { |max_length, name|  max_length < name.length ? name.length : max_length }
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
        name = name.to_s

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
          out << format_header(var,@headers_options) if @headers_options[:show] = true && available_fields.key?(var)
          out += available_fields[var] if available_fields.key?(var)
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
