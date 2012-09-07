#encoding: utf-8

module CommandExec
  module Formatter
    class JSON < CommandExec::Formatter::Hash
      def output(*fields)
        ::JSON.generate prepare_output(fields.flatten) 
      end
    end
  end
end
