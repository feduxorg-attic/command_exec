#encoding: utf-8

#Main
module CommandExec
  #Formatting output
  module Formatter
    #Style as xml string
    class XML < CommandExec::Formatter::Hash
      # convert the prepared output to a xml string
      #
      # @param [Array,Symbol) fields
      #   the fields which should be outputted
      #
      # @return [String] 
      #   the output formatted as a xml string
      def output(*fields)
        XmlSimple.xml_out(prepare_output(fields.flatten), 'RootName' => 'command', 'NoAttr' => true)
      end
    end
  end
end
