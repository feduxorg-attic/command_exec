#encoding: utf-8

require 'spec_helper'

describe Formatter::XML do
  before :each do
    @formatter = Formatter::XML.new
  end

  it "outputs data as XML string" do
      @formatter.stderr(["output of stderr"])
      @formatter.stdout("output of stdout")
      @formatter.log_file("output of log file")
      @formatter.return_code("output of return code")
      @formatter.status(:failed)

      expect(@formatter.output(:stdout,:stderr)).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<command>\n  <stdout type=\"array\">\n    <stdout>output of stdout</stdout>\n  </stdout>\n  <stderr type=\"array\">\n    <stderr>output of stderr</stderr>\n  </stderr>\n</command>\n")
  end
end
