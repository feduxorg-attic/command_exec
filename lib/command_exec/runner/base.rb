# encoding: utf-8

# Classes concerning command execution
module CommandExec
  # Run commands
  module Runner
    class Base
      private

      # @!attribute [r] logger
      #   the logger
      attr_reader   :logger, :runtime_logger

      public

      # Create new runner
      #
      # @param [#debug,#info,#warn,#error] logger
      #   the logger
      def initialize(logger)
        @logger = logger
        @runtime_logger = RuntimeLogger.new
      end

      # Run command
      def run(*args)
        runtime_logger.start

        process = _run(*args)

        runtime_logger.stop
        process.runtime = runtime_logger.duration

        process
      end
    end
  end
end
