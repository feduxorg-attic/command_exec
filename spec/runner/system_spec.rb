# encoding: utf-8
require 'spec_helper'

describe Runner::System do
  context '#run' do
    it 'runs the command' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 0
      EOS

      file = create_file('cmd', content, 0755)

      command = double('Commmand')
      expect(command).to receive(:to_s).and_return(file)
      expect(command).to receive(:working_directory).and_return(working_directory)

      logger = double('Logger')
      allow(logger).to receive(:debug)
      allow(logger).to receive(:info)
      allow(logger).to receive(:warn)
      allow(logger).to receive(:error)

      runner = Runner::System.new(logger)
      runner.run(command)
    end

    it 'records results' do
      content = <<-EOS.strip_heredoc
      #!/usr/bin/bash
      exit 128
      EOS

      file = create_file('cmd', content, 0755)

      command = double('Commmand')
      expect(command).to receive(:to_s).and_return(file)
      expect(command).to receive(:working_directory).and_return(working_directory)

      logger = double('Logger')
      allow(logger).to receive(:debug)
      allow(logger).to receive(:info)
      allow(logger).to receive(:warn)
      allow(logger).to receive(:error)

      runner = Runner::System.new(logger)
      result = runner.run(command)

      expect(result.return_code).to eq(128)
    end
  end
end
