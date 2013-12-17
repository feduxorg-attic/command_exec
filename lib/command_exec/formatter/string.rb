# encoding: utf-8

# Main
module CommandExec
  # Formatting output
  module Formatter
    # Style as simple string
    class String < CommandExec::Formatter::Array
      # convert the prepared output to single string
      #
      # @param [Array,Symbol) fields
      #   the fields which should be outputted
      #
      # @return [String]
      #   the output formatted as simple string
      def output(*fields)
        prepare_output(fields.flatten).join("\n")
      end
    end
  end
end
