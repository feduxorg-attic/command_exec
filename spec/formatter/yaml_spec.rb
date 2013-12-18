# encoding: utf-8

require 'spec_helper'

describe Formatter::YAML do
  before :each do
    @formatter = Formatter::YAML.new
  end

  it 'outputs data as yaml string' do
      @formatter.stderr(['output of stderr'])
      @formatter.stdout('output of stdout')
      @formatter.log_file('output of log file')
      @formatter.return_code('output of return code')
      @formatter.pid(4711)
      @formatter.status(:failed)
      @formatter.executable('/usr/bin/true')

      expect(@formatter.output(:stdout, :stderr)).to eq("---\n:stdout:\n- output of stdout\n:stderr:\n- output of stderr\n")
  end
end
