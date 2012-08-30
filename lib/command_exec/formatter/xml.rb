#encoding: utf-8

module CommandExec
  module Formatter
    class XML < Hash
      def output(*fields)
        prepare_output(fields.flatten).to_xml(root: 'command')
      end
    end
  end
end
