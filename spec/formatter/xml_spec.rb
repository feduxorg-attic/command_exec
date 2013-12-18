# encoding: utf-8

require 'spec_helper'

describe Formatter::XML do
  before :each do
    @formatter = Formatter::XML.new
  end

  it 'outputs data as XML string' do
      @formatter.stderr(['output of stderr'])
      @formatter.stdout('output of stdout')
      @formatter.log_file('output of log file')
      @formatter.return_code('output of return code')
      @formatter.pid(4711)
      @formatter.status(:failed)
      @formatter.executable('/usr/bin/true')

      expect(@formatter.output(:stdout, :stderr)).to eq("<command>\n  <stdout>output of stdout</stdout>\n  <stderr>output of stderr</stderr>\n</command>\n")
  end

  it 'outputs data as XML string (attributes with multiple values)' do
      @formatter.stderr(['output of stderr 1/2', 'output of stderr 2/2'])
      @formatter.stdout('output of stdout')
      @formatter.log_file('output of log file')
      @formatter.return_code('output of return code')
      @formatter.pid(4711)
      @formatter.status(:failed)
      @formatter.executable('/usr/bin/true')

      expect(@formatter.output(:stdout, :stderr)).to eq("<command>\n  <stdout>output of stdout</stdout>\n  <stderr>output of stderr 1/2</stderr>\n  <stderr>output of stderr 2/2</stderr>\n</command>\n")
  end
end
