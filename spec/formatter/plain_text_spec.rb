require 'spec_helper'

describe Formatter::PlainText do
  let(:formatter) { Formatter::Plaintext.new }

  it "outputs stderr with header" do
    expect(formatter.stderr("stdout")).to eq()

  end
end
