# encoding: utf-8

# Classes concerning command execution
module CommandExec
  # Run commands
  module Runner
    class Base
      private

      # @!attribute [r] logger
      #   the logger
      attr_reader   :logger

      public

      # Create new runner
      #
      # @param [#debug,#info,#warn,#error] logger
      #   the logger
      def initialize(logger)
        @logger = logger
      end

      # Run command
      def run(*args)
        _run(*args)
      end
    end
  end
end
