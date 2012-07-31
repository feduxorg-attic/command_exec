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

    def create_tmp_file_with(base_name, content)
      file = Tempfile.new(base_name)
      file.write(content)
      file.rewind

      file
    end
  end
end
