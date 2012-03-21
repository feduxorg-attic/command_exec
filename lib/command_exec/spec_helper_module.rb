module CommandExec
  module SpecHelper
    def capture_stderr(&block)
      previous_stderr, $stderr = $stderr, StringIO.new
      block.call
      return $stderr.string
    ensure
      $stderr = previous_stderr
    end

    def capture_stdout(&block)
      previous_stdout, $stdout = $stdout, StringIO.new
      block.call
      return $stdout.string
    ensure
      $stdout = previous_stdout
    end
  end
end
