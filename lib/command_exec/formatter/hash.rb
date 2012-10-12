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
          @status[0] = 'OK'
        when 'failed'
          @status[0] = 'FAILED'
        else
          @status[0] = 'FAILED'
        end

        @status
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
          out[f] = available_fields[f] if available_fields.has_key?(f)
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
