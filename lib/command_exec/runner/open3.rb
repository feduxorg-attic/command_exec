# encoding: utf-8
module CommandExec
  module Runner
    class Open3
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

        ::Open3::popen3(command.to_s, chdir: command.working_directory) do |stdin, stdout, stderr, wait_thr|
          process.stdout      = stdout.readlines.map(&:chomp)
          process.stderr      = stderr.readlines.map(&:chomp)
          process.pid         = wait_thr.pid
          process.return_code = wait_thr.value.exitstatus

          process
        end
      end
    end
  end
end
