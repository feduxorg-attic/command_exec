require 'spec_helper'

describe Formatter::PlainText do
  it "outputs stderr with header" do
    formatter = Formatter::PlainText.new
    expect(formatter.stderr(["output on stdout"])).to eq(["======= STDERR      =======", "output on stdout"])

    formatter = Formatter::PlainText.new
    expect(formatter.stderr("output on stdout")).to eq(["======= STDERR      =======", "output on stdout"])
  end

  it "outputs" do
    formatter = Formatter::PlainText.new
    formatter.stderr(["output on stdout"])
    formatter.stderr(["output on stdout"])
    expect(formatter.output(:stderr)).to eq(["======= STDERR      =======", "output on stdout", "output on stdout"])
  end
end
