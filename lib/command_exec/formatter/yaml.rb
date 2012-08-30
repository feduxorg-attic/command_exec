# encoding: utf-8

module CommandExec
  module Formatter
    class YAML < Hash
      def output(*fields)
        Psych.dump prepare_output(fields.flatten) 
      end
    end
  end
end
