#encoding: utf-8

module CommandExec
  module Formatter
    class JSON < Hash
      def output(*fields)
        ::JSON.generate prepare_output(fields.flatten) 
      end
    end
  end
end
