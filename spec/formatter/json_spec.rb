#encoding: utf-8

require 'spec_helper'

describe Formatter::JSON do
  before :each do
    @formatter = Formatter::JSON.new
  end

  it "outputs data as json string" do
      @formatter.stderr(["output of stderr"])
      @formatter.stdout("output of stdout")
      @formatter.log_file("output of log file")
      @formatter.return_code("output of return code")
      @formatter.pid(4711)
      @formatter.status(:failed)

      expect(@formatter.output(:stdout,:stderr)).to eq("{\"stdout\":[\"output of stdout\"],\"stderr\":[\"output of stderr\"]}")
  end
end
