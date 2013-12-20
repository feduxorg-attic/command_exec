# encoding: utf-8
module CommandExec
  module Runner
    class System
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

      # Create new runner
      #
      # @param [#to_s,#working_directory] command
      #   the command to be run
      def run(command)
        process = Process.new(lib_logger: logger)

        Dir.chdir(command.working_directory) do
          system(command.to_s)
          process.stdout      = []
          process.stderr      = []
          process.pid         = $?.pid
          process.return_code = $?.exitstatus

          process
        end
      end
    end
  end
end
