# encoding: utf-8

# Main
module CommandExec
  # Formatting output
  module Formatter
    # Style as json string
    class JSON < CommandExec::Formatter::Hash
      # convert the prepared output to json
      #
      # @param [Array,Symbol) fields
      #   the fields which should be outputted
      #
      # @return [String] 
      #   the output formatted as json string
      def output(*fields)
        ::JSON.generate prepare_output(fields.flatten) 
      end
    end
  end
end
