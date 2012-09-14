#encoding: utf-8

module CommandExec
  module Formatter
    class String < CommandExec::Formatter::Array
      def output(*fields)
        prepare_output(fields.flatten).join("\n")
      end
    end
  end
end
