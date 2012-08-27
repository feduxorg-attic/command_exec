require 'spec_helper'

describe Formatter::PlainText do
  it "formats headers (plain)" do
    formatter = Formatter::PlainText.new
    expect(formatter.format_header(:reason_for_failure)).to eq("===== REASON FOR FAILURE =====")
    expect(formatter.format_header(:status)).to eq("=====       STATUS       =====")
  end

  it "formats headers and modifies prefix" do
    formatter = Formatter::PlainText.new
    expect(formatter.format_header(:status, prefix: '-' * 5 )).to eq("-----       STATUS       =====")
  end

  it "formats headers and modifies suffix" do
    formatter = Formatter::PlainText.new
    expect(formatter.format_header(:status, suffix: '-' * 5 )).to eq("=====       STATUS       -----")
  end

  it "formats headers and modifies suffix/prefix" do
    formatter = Formatter::PlainText.new
    expect(formatter.format_header(:status, prefix: '#' * 5, suffix: '-' * 5 )).to eq("#####       STATUS       -----")
  end

  it "leaves out nil prefix/suffix" do
    formatter = Formatter::PlainText.new
    expect(formatter.format_header(:status, prefix: nil , suffix: nil)).to eq("      STATUS      ")
  end

  it "finds the longest header names' length" do
    formatter = Formatter::PlainText.new
    expect(formatter.max_header_length).to eq(18)
  end

  it "centers header names" do
    formatter = Formatter::PlainText.new
    expect(formatter.halign_center( '012' , 10 )).to        eq('   012    ')
    expect(formatter.halign_center( '0123' , 10 )).to       eq('   0123   ')
    expect(formatter.halign_center( '0123456789' , 10 )).to eq('0123456789')
    expect(formatter.halign_center( '012' , 11 )).to         eq('    012    ')
    expect(formatter.halign_center( '0123' , 11 )).to        eq('   0123    ')
    expect(formatter.halign_center( '01234567891' , 11 )).to eq('01234567891')
  end

  it "leftify header names" do
    formatter = Formatter::PlainText.new
    expect(formatter.halign_left( '012' , 10 )).to        eq('012       ')
    expect(formatter.halign_left( '0123' , 10 )).to       eq('0123      ')
    expect(formatter.halign_left( '0123456789' , 10 )).to eq('0123456789')
    expect(formatter.halign_left( '012' , 11 )).to         eq('012        ')
    expect(formatter.halign_left( '0123' , 11 )).to        eq('0123       ')
    expect(formatter.halign_left( '01234567891' , 11 )).to eq('01234567891')
  end

  it "justify header names right" do
    formatter = Formatter::PlainText.new
    expect(formatter.halign_right( '012' , 10 )).to        eq('       012')
    expect(formatter.halign_right( '0123' , 10 )).to       eq('      0123')
    expect(formatter.halign_right( '0123456789' , 10 )).to eq('0123456789')
    expect(formatter.halign_right( '012' , 11 )).to         eq('        012')
    expect(formatter.halign_right( '0123' , 11 )).to        eq('       0123')
    expect(formatter.halign_right( '01234567891' , 11 )).to eq('01234567891')
  end

  it "decides how to align header" do
    formatter = Formatter::PlainText.new
    expect(formatter.halign( '012' , 11 , :center)).to         eq('    012    ')
    expect(formatter.halign( '012' , 10 , :left)).to        eq('012       ')
    expect(formatter.halign( '012' , 10 , :right)).to        eq('       012')
    expect(formatter.halign( '012' , 11 , :unknown)).to         eq('    012    ')
  end

  it "outputs stderr with header" do
    formatter = Formatter::PlainText.new
    expect(formatter.stderr("output of stderr")).to eq(["output of stderr"])
  end

  it "supports arrays as well" do
    formatter = Formatter::PlainText.new
    expect(formatter.stderr(["output of stderr"])).to eq(["output of stderr"])
  end

  it "outputs multiple values if called multiple times (but only with one header)" do
    formatter = Formatter::PlainText.new
    2.times do
      formatter.stderr(["output of stderr"])
    end
    expect(formatter.output(:stderr)).to eq(["=====       STDERR       =====", "output of stderr", "output of stderr"])
  end

  it "outputs stdout" do
    formatter = Formatter::PlainText.new
    expect(formatter.stdout("output of stdout")).to eq(["output of stdout"])
  end

  it "outputs log file" do
    formatter = Formatter::PlainText.new
    expect(formatter.log_file("output of log file")).to eq(["output of log file"])
  end

  it "outputs return code" do
    formatter = Formatter::PlainText.new
    expect(formatter.return_code("output of return code")).to eq(["output of return code"])
  end

  it "outputs status" do
    formatter = Formatter::PlainText.new
    expect(formatter.status(:failed)).to eq([ "\e[1m\e[1;32mFAILED\e[0m\e[0m"])
    expect(formatter.status(:success)).to eq(["\e[1m\e[1;32mOK\e[0m\e[0m"])
    expect(formatter.status(:unknown)).to eq([ "\e[1m\e[1;32mFAILED\e[0m\e[0m"])
  end

  it "outputs status as single value (no data is appended)" do
    formatter = Formatter::PlainText.new
    formatter.status(:success)
    formatter.status(:failed)
    expect(formatter.output(:status)).to eq(["=====       STATUS       =====", "\e[1m\e[1;32mFAILED\e[0m\e[0m"])
  end

  it "supports status as string as well" do
    formatter = Formatter::PlainText.new
    expect(formatter.status('failed')).to eq(["\e[1m\e[1;32mFAILED\e[0m\e[0m"])
    expect(formatter.status('success')).to eq([ "\e[1m\e[1;32mOK\e[0m\e[0m"])
  end

  it "supports blank headers" do
    formatter = Formatter::PlainText.new(headers: { names: { return_code: "" }})
    formatter.return_code("output of return code")
    expect(formatter.output(:return_code)).to eq(["" , "output of return code"])
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
    formatter.reason_for_failure('great an error occured')

    expect(formatter.output(:stderr)).to eq([
                                    "=====       STDERR       =====",
                                    "output of stderr",
                                    ])
    expect(formatter.output).to eq([
                                    "=====       STATUS       =====",
                                    "\e[1m\e[1;32mFAILED\e[0m\e[0m",
                                    "=====    RETURN CODE     =====",
                                    "output of return code",
                                    "=====       STDERR       =====",
                                    "output of stderr",
                                    "=====       STDOUT       =====",
                                    "output of stdout",
                                    "=====      LOG FILE      =====",
                                    "output of log file",
                                    "===== REASON FOR FAILURE =====",
                                    'great an error occured'
                                    ])
    expect(formatter.output(:stdout,:stderr)).to eq([
                                    "=====       STDOUT       =====",
                                    "output of stdout",
                                    "=====       STDERR       =====",
                                    "output of stderr",
                                    ])
  end

  it "accepts a reason for a failure" do
    formatter = Formatter::PlainText.new
    expect(formatter.reason_for_failure('error in stdout found')).to eq([ "error in stdout found" ])
  end

  it "output only wanted values (given as array)" do
    formatter = Formatter::PlainText.new
    formatter.stderr(["output of stderr"])
    formatter.stdout("output of stdout")
    formatter.log_file("output of log file")
    formatter.return_code("output of return code")
    formatter.status(:failed)

    expect(formatter.output([:stdout,:stderr])).to eq([
                                    "=====       STDOUT       =====",
                                    "output of stdout",
                                    "=====       STDERR       =====",
                                    "output of stderr"
                                    ])
  end
end
