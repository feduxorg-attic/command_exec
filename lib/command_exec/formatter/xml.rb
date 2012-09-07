#encoding: utf-8

module CommandExec
  module Formatter
    class XML < Hash
      def output(*fields)
        XmlSimple.xml_out(prepare_output(fields.flatten), 'RootName' => 'command', 'NoAttr' => true)
      end
    end
  end
end
