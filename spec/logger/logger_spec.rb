require 'spec_helper'

describe Logger do

  let(:logger) {Logger.new(STDOUT)}

  it "supports all constants of normal logger implementation + one extra" do
   expect{ Logger::SILENT }.to_not raise_error
  end
end
