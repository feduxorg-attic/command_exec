#encoding: utf-8

require 'spec_helper'

describe Formatter::Array do

  before(:each) do
    @formatter = Formatter::Array.new
  end

  context :private_api do

    it "formats headers (plain)" do
      expect(@formatter.send(:format_header,:reason_for_failure)).to eq("===== REASON FOR FAILURE =====")
      expect(@formatter.send(:format_header,:status)).to eq("=====       STATUS       =====")
    end

    it "formats headers and modifies prefix" do
      expect(@formatter.send(:format_header,:status, prefix: '-' * 5)).to eq("-----       STATUS       =====")
    end

    it "formats headers and modifies suffix" do
      expect(@formatter.send(:format_header,:status, suffix: '-' * 5)).to eq("=====       STATUS       -----")
    end

    it "formats headers and modifies suffix/prefix" do
      expect(@formatter.send(:format_header,:status, prefix: '#' * 5, suffix: '-' * 5)).to eq("#####       STATUS       -----")
    end

    it "leaves out nil prefix/suffix" do
      expect(@formatter.send(:format_header,:status, prefix: nil, suffix: nil)).to eq("      STATUS      ")
    end

    it "finds the longest header names' length" do
      expect(@formatter.send(:max_header_length)).to eq(18)
    end

    it "centers header names" do
      expect(@formatter.send(:halign, '012', 10, :center)).to        eq('   012    ')
      expect(@formatter.send(:halign, '0123', 10, :center)).to       eq('   0123   ')
      expect(@formatter.send(:halign, '0123456789', 10, :center)).to eq('0123456789')
      expect(@formatter.send(:halign, '012', 11, :center)).to         eq('    012    ')
      expect(@formatter.send(:halign, '0123', 11, :center)).to        eq('   0123    ')
      expect(@formatter.send(:halign, '01234567891', 11, :center)).to eq('01234567891')

      #default = center
      expect(@formatter.send(:halign, '01234567891', 11, :unknown)).to eq('01234567891')
    end

    it "leftify header names" do
      expect(@formatter.send(:halign, '012', 10, :left)).to        eq('012       ')
      expect(@formatter.send(:halign, '0123', 10, :left)).to       eq('0123      ')
      expect(@formatter.send(:halign, '0123456789', 10, :left)).to eq('0123456789')
      expect(@formatter.send(:halign, '012', 11, :left)).to         eq('012        ')
      expect(@formatter.send(:halign, '0123', 11, :left)).to        eq('0123       ')
      expect(@formatter.send(:halign, '01234567891', 11, :left)).to eq('01234567891')
    end

    it "justify header names right" do
      expect(@formatter.send(:halign, '012', 10, :right)).to        eq('       012')
      expect(@formatter.send(:halign, '0123', 10, :right)).to       eq('      0123')
      expect(@formatter.send(:halign, '0123456789', 10, :right)).to eq('0123456789')
      expect(@formatter.send(:halign, '012', 11, :right)).to         eq('        012')
      expect(@formatter.send(:halign, '0123', 11, :right)).to        eq('       0123')
      expect(@formatter.send(:halign, '01234567891', 11, :right)).to eq('01234567891')
    end

  end

  context :public_api do

    it "outputs stderr with header" do
      expect(@formatter.stderr("output of stderr")).to eq(["output of stderr"])
    end

    it "supports arrays as well" do
      expect(@formatter.stderr(["output of stderr"])).to eq(["output of stderr"])
    end

    it "outputs multiple values if called multiple times (but only with one header)" do
      2.times do
        @formatter.stderr(["output of stderr"])
      end
      expect(@formatter.output(:stderr)).to eq(["=====       STDERR       =====", "output of stderr", "output of stderr"])
    end

    it "outputs stdout" do
      expect(@formatter.stdout("output of stdout")).to eq(["output of stdout"])
    end

    it "outputs log file" do
      expect(@formatter.log_file("output of log file")).to eq(["output of log file"])
    end

    it "outputs return code" do
      expect(@formatter.return_code("output of return code")).to eq(["output of return code"])
    end

    it "outputs status" do
      expect(@formatter.status(:failed)).to eq(["\e[1;31mFAILED\e[0m"])
      expect(@formatter.status(:success)).to eq(["\e[1;32mOK\e[0m"])
      expect(@formatter.status(:unknown)).to eq(["\e[1;31mFAILED\e[0m"])
    end

    it "outputs status as single value (no data is appended)" do
      @formatter.status(:success)
      @formatter.status(:failed)
      expect(@formatter.output(:status)).to eq(["=====       STATUS       =====", "\e[1;31mFAILED\e[0m"])
    end

    it "supports status as string as well" do
      expect(@formatter.status('failed')).to eq(["\e[1;31mFAILED\e[0m"])
      expect(@formatter.status('success')).to eq(["\e[1;32mOK\e[0m"])
    end

    it "supports blank headers" do
      formatter = Formatter::Array.new(headers: {names: {return_code: ""}})
      formatter.return_code("output of return code")
      expect(formatter.output(:return_code)).to eq(["", "output of return code"])
    end

    it "suppresses headers if nil" do
      expect(@formatter.return_code("output of return code")).to eq(["output of return code"])
    end

    it "output only wanted values" do
      @formatter.stderr(["output of stderr"])
      @formatter.stdout("output of stdout")
      @formatter.log_file("output of log file")
      @formatter.return_code("output of return code")
      @formatter.status(:failed)
      @formatter.pid(4711)
      @formatter.reason_for_failure('great an error occured')
      @formatter.executable('/usr/bin/true')
      start_time = Time.now
      end_time= start_time + 2.seconds
      @formatter.start_time(start_time)
      @formatter.end_time(end_time)

      expect(@formatter.output(:stderr)).to eq([
        "=====       STDERR       =====",
        "output of stderr",
      ])
      expect(@formatter.output).to eq([
        "=====       STATUS       =====",
        "\e[1;31mFAILED\e[0m",
        "=====    RETURN CODE     =====",
        "output of return code",
        "=====       STDERR       =====",
        "output of stderr",
        "=====       STDOUT       =====",
        "output of stdout",
        "=====      LOG FILE      =====",
        "output of log file",
        "=====        PID         =====",
        '4711',
        "===== REASON FOR FAILURE =====",
        'great an error occured',
        "=====     EXECUTABLE     =====",
        "/usr/bin/true",
        "=====     START TIME     =====",
        start_time,
        "=====      END TIME      =====",
        end_time,
      ])
      expect(@formatter.output(:stdout,:stderr)).to eq([
        "=====       STDOUT       =====",
        "output of stdout",
        "=====       STDERR       =====",
        "output of stderr",
      ])
    end

    it "accepts a reason for a failure" do
      expect(@formatter.reason_for_failure('error in stdout found')).to eq(["error in stdout found"])
    end

    it "outputs only wanted values (given as array)" do
      @formatter.stderr(["output of stderr"])
      @formatter.stdout("output of stdout")
      @formatter.log_file("output of log file")
      @formatter.return_code("output of return code")
      @formatter.status(:failed)

      expect(@formatter.output([:stdout,:stderr])).to eq([
        "=====       STDOUT       =====",
        "output of stdout",
        "=====       STDERR       =====",
        "output of stderr"
      ])
    end

    it "outputs only wanted values in the given order)" do
      @formatter.stderr(["output of stderr"])
      @formatter.stdout("output of stdout")
      @formatter.log_file("output of log file")
      @formatter.return_code("output of return code")
      @formatter.status(:failed)

      expect(@formatter.output([:stdout,:stderr])).to eq([
        "=====       STDOUT       =====",
        "output of stdout",
        "=====       STDERR       =====",
        "output of stderr",
      ])

      expect(@formatter.output([:stderr,:stdout])).to eq([
        "=====       STDERR       =====",
        "output of stderr",
        "=====       STDOUT       =====",
        "output of stdout",
      ])
    end
  end
end
