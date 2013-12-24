# encoding: utf-8

require 'spec_helper'

describe Command do
  let(:lib_logger)do
    lib_logger = double('LibLogger')
    allow(lib_logger).to receive(:debug)
    allow(lib_logger).to receive(:info)
    allow(lib_logger).to receive(:warn)
    allow(lib_logger).to receive(:error)
    allow(lib_logger).to receive(:mode=)

    lib_logger
  end

  let(:command) do
    Command.new(:echo, lib_logger: lib_logger, parameter: 'hello world', error_keywords: %q[abc def], working_directory: '/tmp')
  end

  # before(:all)do
  #  # CommandExec.search_paths = [File.join(examples_directory, 'command'), '/bin', '/usr/bin']
  # end

  context '# run' do
    it 'supports relative paths' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/env bash
      exit 1
      EOS

      create_file('cmd', content, 0755)

      switch_to_working_directory do
        command = Command.new('cmd')
        expect { command.run }.not_to raise_error
      end
    end

    it 'supports relative paths with dot' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/env bash
      exit 1
      EOS

      create_file('cmd', content, 0755)

      switch_to_working_directory do
        command = Command.new('./cmd')
        expect { command.run }.not_to raise_error
      end
    end

    it 'supports absolute paths' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/env bash
      exit 1
      EOS

      file = create_file('cmd', content, 0755)

      switch_to_working_directory do
        command = Command.new(file)
        expect { command.run }.not_to raise_error
      end
    end

    it 'searches $PATH to find the command' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/env bash
      exit 1
      EOS

      create_file('cmd', content, 0755)

      with_environment 'PATH' => working_directory do
        command = Command.new(:cmd)
        expect { command.run }.not_to raise_error
      end

    end

    it 'offers an option to change search path PATH for the command execution' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/env bash
      exit 1
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd, search_paths: [working_directory])
      expect { command.run }.not_to raise_error
    end

    it 'accepts options for command' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      echo $*
      exit 1
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd, options: '-q hello world', search_paths: [working_directory])
      result = command.run
      expect(result.stdout).to eq(['-q hello world'])
    end

    it 'has parameter' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      echo $*
      exit 1
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd, parameter: 'hello world', search_paths: [working_directory])
      result = command.run
      expect(result.stdout).to eq(['hello world'])
    end

    it 'meassures runtime' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      sleep 1
      exit 1
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd, search_paths: [working_directory])
      result = command.run
      expect(result.runtime.to_i).to eq(1)
    end
  end

  context '#to_s' do
    it 'can be used to construct a command string, which can be executed' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 1
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd, parameter: 'hello world', search_paths: [working_directory])
      expect(command.to_s).to eq(File.join(working_directory, 'cmd') + ' hello world')
    end

    it 'fails if command cannot be found' do
      expect do
        Command.new(:cmd, parameter: 'hello world', search_paths: [working_directory])
      end.to raise_error CommandExec::Exceptions::CommandNotFound
    end
  end

  context '#execute' do
    it 'execute existing programs' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 0
      EOS

      create_file('cmd', content, 0755)

      silence(:stdout)do
        command = Command.execute(:cmd, search_paths: [working_directory])
        expect(command.result.status).to eq(:success)
      end
    end
  end

  context '#run' do
    it 'offers the possibility to change the working directory of the process without any side effects' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 0
      EOS

      create_file('cmd', content, 0755)
      command = Command.new(:cmd, search_paths: [working_directory], working_directory: '/tmp')

      expect(command.working_directory).to eq('/tmp')

      # no side effects: the working directory of rspec is the same as before
      ->{ command.run }

      expect(Dir.pwd).to eq(File.expand_path('..', File.dirname(__FILE__)))
    end

    it 'runs programms' do
      silence(:stdout)do
        content = <<-EOS.strip_heredoc
        #!/usr/bin/bash
        exit 0
        EOS

        create_file('cmd', content, 0755)
        command = Command.new(:cmd, search_paths: [working_directory])
        expect(command.run.status).to eq(:success)
      end
    end

    it 'produces output on debug, info, warn, error-loglevel' do
      # if you choose the system runner output of commands will be not suppressed'
      logger = double('LocalLogger')
      allow(logger).to receive(:debug)
      allow(logger).to receive(:info)
      allow(logger).to receive(:warn)
      allow(logger).to receive(:error)
      allow(logger).to receive(:mode=)

      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 0
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd, search_paths: [working_directory], lib_logger: logger)
      command.run
    end

    it 'is silent and returns no output' do
      # if you choose the system runner output of commands will be not suppressed'
      logger = double('LocalLogger')
      allow(logger).to receive(:debug)
      allow(logger).to receive(:info)
      allow(logger).to receive(:warn)
      allow(logger).to receive(:error)
      expect(logger).to receive(:mode=).with(:silent)

      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 0
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd, search_paths: [working_directory], lib_logger: logger, lib_log_level: :silent)
      command.run
    end

    it 'outputs only warnings when told to output those' do
      logger = double('LocalLogger')
      allow(logger).to receive(:debug)
      allow(logger).to receive(:info)
      allow(logger).to receive(:warn)
      expect(logger).to receive(:warn).with('Logfile does_not_exist not found!')
      allow(logger).to receive(:error)
      allow(logger).to receive(:mode=)

      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 0
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd, search_paths: [working_directory], lib_logger: logger, log_file: 'does_not_exist')
      command.run
    end

    it 'considers status for error handling (default 0)' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 1
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            error_detection_on: [:return_code]
                           )
      expect(command.run.status).to eq(:failed)
    end

    it 'considers status for error handling (single value as array)' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 1
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            error_detection_on: [:return_code],
                            error_indicators: { allowed_return_code: [0] }
                           )
      expect(command.run.status).to eq(:failed)
    end

    it 'considers status for error handling (single value as symbol)' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 1
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            error_detection_on: :return_code,
                            error_indicators: { allowed_return_code: [0] }
                           )
      expect(command.run.status).to eq(:failed)
    end

    it 'considers status for error handling (single value)' do
      content_0 = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 0
      EOS

      content_2 = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 2
      EOS

      create_file('cmd_0', content_0, 0755)
      create_file('cmd_2', content_2, 0755)

      command = Command.new(:cmd_0,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            error_detection_on: :return_code,
                            error_indicators: { allowed_return_code: [0, 2] }
                           )
      expect(command.run.status).to eq(:success)

      command = Command.new(:cmd_2,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            error_detection_on: :return_code,
                            error_indicators: { allowed_return_code: [0, 2] }
                           )

      expect(command.run.status).to eq(:success)
    end

    it 'considers stderr for error handling' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      echo error >&2
      exit 0
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            error_detection_on: :stderr,
                            error_indicators: { forbidden_words_in_stderr: %w{error} }
                           )
      expect(command.run.status).to eq(:failed)
    end

    it 'considers stderr for error handling but can make exceptions' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      echo error. execution failed >&2
      exit 0
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            error_detection_on: :stderr,
                            error_indicators: { forbidden_words_in_stderr: %w{error}, allowed_words_in_stderr: ['error. execution failed'] }
                           )
      expect(command.run.status).to eq(:success)
    end

    it 'considers stdout for error handling' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      echo error
      exit 0
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            error_detection_on: :stdout,
                            error_indicators: { forbidden_words_in_stdout: %w{error} }
                           )
      expect(command.run.status).to eq(:failed)
    end

    it 'considers log file for error handling' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 0
      EOS
      create_file('cmd', content, 0755)

      content = <<-EOS.strip_heredoc
      error
      error
      EOS
      logfile = create_file('logfile', content, 0644)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            log_file: logfile,
                            error_detection_on: :log_file,
                            error_indicators: { forbidden_words_in_log_file: %w{error} }
                           )
      expect(command.run.status).to eq(:failed)
    end

    it 'returns the result of command execution as process object (defaults to :return_process_information)' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 0
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            error_detection_on: :return_code,
                            error_indicators: { allowed_return_code: [0] }
                           )
      expect(command.run).to respond_to(:status)
    end

    it 'returns the result of command execution as process object' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 0
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            on_error_do: :return_process_information,
                            error_detection_on: :return_code,
                            error_indicators: { allowed_return_code: [0] }
                           )
      expect(command.run).to respond_to(:status)
    end

    it 'does nothing on error if told so' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 1
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            on_error_do: :nothing,
                            error_detection_on: :return_code,
                            error_indicators: { allowed_return_code: [0] }
                           )
      expect { command.run }.to_not raise_error
      expect { command.run }.to_not throw_symbol
    end

    it 'raises an exception' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 1
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            on_error_do: :raise_error,
                            error_detection_on: :return_code,
                            error_indicators: { allowed_return_code: [0] }
                           )

      expect { command.run }.to raise_error(CommandExec::Exceptions::CommandExecutionFailed)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            on_error_do: :raise_error,
                            error_detection_on: :return_code,
                            error_indicators: { allowed_return_code: [1] }
                           )
      expect { command.run }.to_not raise_error
    end

    it 'throws an error' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 1
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            on_error_do: :throw_error,
                            error_detection_on: :return_code,
                            error_indicators: { allowed_return_code: [0] }
                           )
      expect { command.run }.to throw_symbol(:command_execution_failed)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            on_error_do: :throw_error,
                            error_detection_on: :return_code,
                            error_indicators: { allowed_return_code: [1] }
                           )
      expect { command.run }.to_not throw_symbol
    end

    it 'support open3 as runner (default)' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 0
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            run_via: :open3,
                            error_detection_on: :return_code,
                            error_indicators: { allowed_return_code: [0] }
                           )

      expect(command.run.status).to eq(:success)
    end

    it 'support system as runner' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 0
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            run_via: :system,
                            error_detection_on: :return_code,
                            error_indicators: { allowed_return_code: [0] }
                           )

      expect(command.run.status).to eq(:success)
    end

    it 'has a default runner: open3' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 0
      EOS

      create_file('cmd', content, 0755)

      command = Command.new(:cmd,
                            search_paths: [working_directory],
                            lib_logger: lib_logger,
                            run_via: :unknown_runner,
                            error_detection_on: :return_code,
                            error_indicators: { allowed_return_code: [0] }
                           )
      expect(command.run.status).to eq(:success)
    end

    it 'find errors beyond newlines in the string' do
      command = CommandExec::Command.new(:echo ,
                                         options: '-e',
                                         parameter: "\"wow, a test. That's great.\nBut an error occured in this line\"",
                                         error_detection_on: [:stdout],
                                         error_indicators: {
                                           forbidden_words_in_stdout: %w{ error }
                                         },
                                        )
      command.run
      expect(command.result.status).to eq(:failed)
    end
  end
end
