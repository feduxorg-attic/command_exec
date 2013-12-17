# encoding: utf-8
require 'active_support/core_ext/kernel/reporting'

# Main
module CommandExec
  # Helpers for specs
  module SpecHelper
    # Capture stderr
    #
    # @param [Block] block
    def capture_stderr(&block)
      capture(:stderr, &block)
    end

    # Capture stdout
    #
    # @param [Block] block
    def capture_stdout(&block)
      capture(:stdout, &block)
    end

    # Manipulate environment for the given block
    #
    # @param [Hash] env
    #   The environment for the block which should
    #   be merged with ENV
    #
    # @param [Hash] options
    #   Options for environment manipulation
    #
    # @option options [True,False] :clear
    #   Should the environment clear before merge?
    #
    # @yield Block which should be executed
    def environment(env = {}, options = {}, &block)
      previous_environment, environment = ENV.to_hash, env
      ENV.clear if options[:clear] == true
      ENV.update(environment)
      block.call
    ensure
      ENV.clear
      ENV.update previous_environment
    end

    # Create temporary files for testing
    # (which will be deleted when the
    # ruby process terminates)
    #
    # @param [String] base_name
    #   the path to the temporary file
    #
    # @param [String] content
    #   the content which should be written to the file
    #
    # @return [String]
    #   the path to the temporary file
    def create_temp_file_with(base_name, content)
      file = Tempfile.new(base_name)
      file.write(content)
      file.close
      file.path
    end
  end
end
