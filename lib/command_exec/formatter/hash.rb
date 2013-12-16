#encoding: utf-8

#Main
module CommandExec
  #Formatting output
  module Formatter
    #Style hash
    class Hash
      include FieldHelper

      # @!attribute [r] output
      #   return the formatted output
      attr_reader :output
      # @!attribute [w] logger
      #   set the logger after object creation
      attr_writer :logger

      public

      # Create new hash formatter
      # 
      # @param [Hash] options
      #   Options for formatter
      #
      # @option options [Symbol] :logger
      #   Logger to output information. Needs to have the same interface like
      #   the ruby `Logger`-class.
      def initialize(options={})
        @options = {
          logger: Logger.new($stdout),
        }.deep_merge options

        @logger = @options[:logger]

        super()
      end

      def status(value)
        prepare_status(value)
      end

      private

      # Build the data structure for output
      #
      # @param [Array] fields
      #   which fields should be outputted
      #
      # @return [Hash] 
      #   the formatted output
      def prepare_output(fields=[])
        out = {}

        fields = default_fields if fields.blank?

        fields.each do |f|
          out[f] = available_fields[f] if available_fields.key?(f)
        end

        out
      end

      public

      # Output the prepared output
      #
      # @param [Array,Symbol) fields
      #   the fields which should be outputted
      #
      # @return [Hash] 
      #   the formatted output
      def output(*fields)
        prepare_output(fields.flatten)
      end
    end
  end
end
