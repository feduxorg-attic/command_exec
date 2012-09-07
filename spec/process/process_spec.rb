#encoding: utf-8

require 'spec_helper'

describe CommandExec::Process do

  let(:dev_null) { StringIO.new }

  context :private_api do; end

  context :public_api do

    it "has a executable" do
      process = CommandExec::Process.new(logger: Logger.new(dev_null))
      process.executable = '/bin/sh'
      expect(process.executable).to eq('/bin/sh')
    end

    it "opens a log file" do
      process = CommandExec::Process.new(logger: Logger.new(dev_null))
      tmp_file = create_tmp_file_with('process.log' , 'this is content' )
      process.log_file = tmp_file

      expect(process.log_file).to eq(['this is content'])
    end

    it "accepts nil as filename" do
      process = CommandExec::Process.new(logger: Logger.new(dev_null))
      process.log_file = nil

      expect(process.log_file).to eq([])
    end

    it "goes on with a warning, if log file doesn't exists" do
      file = '/tmp/test1234.txt'
      bucket = StringIO.new
      process = CommandExec::Process.new(logger: Logger.new(bucket))
      tmp_file = create_tmp_file_with('process.log' , 'this is content' )
      process.log_file = file
      process.log_file

      expect(bucket.string[file]).to_not eq(nil)
    end

    it "takes stdout" do
      process = CommandExec::Process.new(logger: Logger.new(dev_null)) 
      process.stdout = 'content'
      expect(process.stdout).to eq(['content'])

      process = CommandExec::Process.new(logger: Logger.new(dev_null)) 
      process.stdout = ['content']
      expect(process.stdout).to eq(['content'])
    end

    it "takes stderr" do
      process = CommandExec::Process.new(logger: Logger.new(dev_null)) 
      process.stderr = 'content'
      expect(process.stderr).to eq(['content'])

      process = CommandExec::Process.new(logger: Logger.new(dev_null)) 
      process.stderr = ['content']
      expect(process.stderr).to eq(['content'])
    end

    it "takes a status" do
      process = CommandExec::Process.new(logger: Logger.new(dev_null)) 
      process.status = :failed
      expect(process.status).to eq(:failed)

      process = CommandExec::Process.new(logger: Logger.new(dev_null)) 
      process.status = :success
      expect(process.status).to eq(:success)

      process = CommandExec::Process.new(logger: Logger.new(dev_null)) 
      process.status = :unknown
      expect(process.status).to eq(:failed)
    end

    it "takes a reason for a failure" do
      process = CommandExec::Process.new(logger: Logger.new(dev_null)) 
      process.reason_for_failure = 'this is an error msg'
      expect(process.reason_for_failure).to eq(['this is an error msg'])
    end

    it "takes a return code" do
      process = CommandExec::Process.new(logger: Logger.new(dev_null)) 
      process.return_code = 1
      expect(process.return_code).to eq(1)
    end

    it "returns an array" do
      process = CommandExec::Process.new(logger: Logger.new(dev_null)) 

      process.stderr = "output of stderr"
      process.stdout = "output of stdout"
      process.log_file = create_tmp_file_with('process.log' , 'output of log file' )
      process.return_code = "output of return code"
      process.status = :failed
      process.reason_for_failure = 'great an error occured'

      expect(process.to_a).to eq([
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
        "great an error occured",
      ])

      expect(process.to_a(:status)).to eq([
        "=====       STATUS       =====",
        "\e[1m\e[1;32mFAILED\e[0m\e[0m",
      ])

    end

    it "returns a hash" do
      process = CommandExec::Process.new(logger: Logger.new(dev_null)) 

      process.stderr = "output of stderr"
      process.stdout = "output of stdout"
      process.log_file = create_tmp_file_with('process.log' , 'output of log file' )
      process.return_code = "output of return code"
      process.status = :failed
      process.reason_for_failure = 'great an error occured'

      expect(process.to_h).to eq({ 
        stderr: ["output of stderr"],
        stdout: ["output of stdout"],
        log_file: ["output of log file"],
        return_code: ["output of return code"],
        status: ['FAILED'],
        reason_for_failure: ['great an error occured'],
      })
    end

    it 'returns a string version of process' do
      process = CommandExec::Process.new(logger: Logger.new(dev_null)) 

      process.stderr = "output of stderr"
      process.stdout = "output of stdout"
      process.log_file = create_tmp_file_with('process.log' , 'output of log file' )
      process.return_code = "output of return code"
      process.status = :failed
      process.reason_for_failure = 'great an error occured'

      expect(process.to_s).to eq([
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
        "great an error occured",
      ].join("\n")
                                )
    end

    it 'returns a json encoded string' do
      process = CommandExec::Process.new(logger: Logger.new(dev_null)) 

      process.stderr = "output of stderr"
      process.stdout = "output of stdout"
      process.log_file = create_tmp_file_with('process.log' , 'output of log file' )
      process.return_code = "output of return code"
      process.status = :failed
      process.reason_for_failure = 'great an error occured'

      expect(process.to_json).to eq("{\"status\":[\"FAILED\"],\"return_code\":[\"output of return code\"],\"stderr\":[\"output of stderr\"],\"stdout\":[\"output of stdout\"],\"log_file\":[\"output of log file\"],\"reason_for_failure\":[\"great an error occured\"]}")
    end

    it 'returns a json encoded string and supports unicode as well' do
      process = CommandExec::Process.new(logger: Logger.new(dev_null)) 

      process.stderr = "this is an 'ä'"
      process.stdout = "output of stdout"
      process.log_file = create_tmp_file_with('process.log' , 'output of log file' )
      process.return_code = "output of return code"
      process.status = :failed
      process.reason_for_failure = 'great an error occured'

      expect(process.to_json).to eq("{\"status\":[\"FAILED\"],\"return_code\":[\"output of return code\"],\"stderr\":[\"this is an 'ä'\"],\"stdout\":[\"output of stdout\"],\"log_file\":[\"output of log file\"],\"reason_for_failure\":[\"great an error occured\"]}")
    end

    it 'returns a yaml encoded string' do
      process = CommandExec::Process.new(logger: Logger.new(dev_null)) 

      process.stderr = "output of stderr"
      process.stdout = "output of stdout"
      process.log_file = create_tmp_file_with('process.log' , 'output of log file' )
      process.return_code = "output of return code"
      process.status = :failed
      process.reason_for_failure = 'great an error occured'

      expect(process.to_yaml).to eq("---\n:status:\n- FAILED\n:return_code:\n- output of return code\n:stderr:\n- output of stderr\n:stdout:\n- output of stdout\n:log_file:\n- output of log file\n:reason_for_failure:\n- great an error occured\n")
    end

    it 'returns a xml encoded string' do
      process = CommandExec::Process.new(logger: Logger.new(dev_null)) 

      process.stderr = "output of stderr"
      process.stdout = "output of stdout"
      process.log_file = create_tmp_file_with('process.log' , 'output of log file' )
      process.return_code = "output of return code"
      process.status = :failed
      process.reason_for_failure = 'great an error occured'

      expect(process.to_xml).to eq("<command>\n  <status>FAILED</status>\n  <return_code>output of return code</return_code>\n  <stderr>output of stderr</stderr>\n  <stdout>output of stdout</stdout>\n  <log_file>output of log file</log_file>\n  <reason_for_failure>great an error occured</reason_for_failure>\n</command>\n")
    end

  end

end
