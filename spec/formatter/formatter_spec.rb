require 'spec_helper'

describe Formatter::PlainText do
  it "outputs stderr with header" do
    formatter = Formatter::PlainText.new
    expect(formatter.stderr("output of stderr")).to eq(["======= STDERR      =======", "output of stderr"])
  end

  it "supports arrays as well" do
    formatter = Formatter::PlainText.new
    expect(formatter.stderr(["output of stderr"])).to eq(["======= STDERR      =======", "output of stderr"])
  end

  it "outputs multiple values if called multiple times (but only with one header)" do
    formatter = Formatter::PlainText.new
    2.times do
      formatter.stderr(["output of stderr"])
    end
    expect(formatter.output(:stderr)).to eq(["======= STDERR      =======", "output of stderr", "output of stderr"])
  end

  it "outputs stdout" do
    formatter = Formatter::PlainText.new
    expect(formatter.stdout("output of stdout")).to eq(["======= STDOUT      =======", "output of stdout"])
  end

  it "outputs log file" do
    formatter = Formatter::PlainText.new
    expect(formatter.log_file("output of log file")).to eq(["======= LOG FILE    =======", "output of log file"])
  end

  it "outputs return code" do
    formatter = Formatter::PlainText.new
    expect(formatter.return_code("output of return code")).to eq(["======= RETURN CODE =======", "output of return code"])
  end

  it "outputs status" do
    formatter = Formatter::PlainText.new
    expect(formatter.status(:failed)).to eq(["======= STATUS      =======", "\e[1m\e[1;32mFAILED\e[0m\e[0m"])
  end

  it "outputs status as single value (no data is appended)" do
    formatter = Formatter::PlainText.new
    expect(formatter.status(:failed)).to eq(["======= STATUS      =======", "\e[1m\e[1;32mFAILED\e[0m\e[0m"])
    expect(formatter.status(:success)).to eq(["======= STATUS      =======", "\e[1m\e[1;32mOK\e[0m\e[0m"])
  end

  it "supports status as string as well" do
    formatter = Formatter::PlainText.new
    expect(formatter.status('failed')).to eq(["======= STATUS      =======", "\e[1m\e[1;32mFAILED\e[0m\e[0m"])
    expect(formatter.status('success')).to eq(["======= STATUS      =======", "\e[1m\e[1;32mOK\e[0m\e[0m"])
  end

  it "supports blank headers" do
    formatter = Formatter::PlainText.new(header: { return_code: "" })
    expect(formatter.return_code("output of return code")).to eq(["" , "output of return code"])
  end

  it "suppresses headers if nil" do
    formatter = Formatter::PlainText.new(header: { return_code: nil })
    expect(formatter.return_code("output of return code")).to eq(["output of return code"])
  end

  it "output only wanted values" do
    formatter = Formatter::PlainText.new
    formatter.stderr(["output of stderr"])
    formatter.stdout("output of stdout")
    formatter.log_file("output of log file")
    formatter.return_code("output of return code")
    formatter.status(:failed)

    expect(formatter.output(:stderr)).to eq(["======= STDERR      =======", "output of stderr" ])
    expect(formatter.output).to eq([
                                    "======= STATUS      =======",
                                    "\e[1m\e[1;32mFAILED\e[0m\e[0m",
                                    "======= RETURN CODE =======",
                                    "output of return code",
                                    "======= STDERR      =======",
                                    "output of stderr",
                                    "======= STDOUT      =======",
                                    "output of stdout",
                                    "======= LOG FILE    =======",
                                    "output of log file"
                                    ])
    expect(formatter.output(:stdout,:stderr)).to eq([
                                    "======= STDOUT      =======",
                                    "output of stdout",
                                    "======= STDERR      =======",
                                    "output of stderr",
                                    ])
  end

  it "accepts a reason for a failure" do
    formatter = Formatter::PlainText.new
    expect(formatter.reason_for_failure('error in stdout found')).to eq([
                                                                          "======= REASON FOR FAILURE =======", 
                                                                          "error in stdout found",
                                                                       ])
  end

  it "output only wanted values (given as array)" do
    formatter = Formatter::PlainText.new
    formatter.stderr(["output of stderr"])
    formatter.stdout("output of stdout")
    formatter.log_file("output of log file")
    formatter.return_code("output of return code")
    formatter.status(:failed)

    expect(formatter.output([:stdout,:stderr])).to eq([
                                    "======= STDOUT      =======",
                                    "output of stdout",
                                    "======= STDERR      =======",
                                    "output of stderr",
                                    ])
  end
end
