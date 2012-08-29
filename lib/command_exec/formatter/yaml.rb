# encoding: utf-8

module CommandExec
  module Formatter
    class YAML < Hash

      attr_reader :output
      attr_writer :logger

      public

      def initialize(options={})
        super 
      end

      def output(*fields)
        out = {}

        avail_fields = {
          :status => @status,
          :return_code => @return_code,
          :stderr => @stderr,
          :stdout => @stdout,
          :log_file => @log_file,
          :reason_for_failure => @reason_for_failure,
        }
        fields = [:status,:return_code,:stderr,:stdout,:log_file,:reason_for_failure] if fields.blank?

        fields.flatten.each do |f|
          out[f] = avail_fields[f] if avail_fields.has_key?(f)
        end

        Psych.dump out
      end
    end
  end
end
