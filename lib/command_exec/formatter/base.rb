# encoding: utf-8

module CommandExec
  module Formatter
    class Base

      attr_reader :output
      attr_writer :logger

      def initialize(options={})
        @log_file = []
        @return_code = []
        @stderr = []
        @stdout = []
        @status = []
        @reason_for_failure = []
      end

      def log_file(*content)
        @log_file += content.flatten
      end

      def return_code(*content)
        @return_code += content.flatten
      end

      def stdout(*content)
        @stdout += content.flatten
      end

      def stderr(*content)
        @stderr += content.flatten
      end

      def reason_for_failure(*content)
        @reason_for_failure += content.flatten
      end

    end
  end
end
