#encoding: utf-8

#Main
module CommandExec
  #Formatting output
  module Formatter
    #Style as yaml string
    class YAML < CommandExec::Formatter::Hash
      # convert the prepared output to a yaml string
      #
      # @param [Array,Symbol) fields
      #   the fields which should be outputted
      #
      # @return [String] 
      #   the output formatted as a xml string
      def output(*fields)
        Psych.dump prepare_output(fields.flatten) 
      end
    end
  end
end
