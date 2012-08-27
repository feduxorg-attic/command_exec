require 'spec_helper'

describe CommandExec::Process do

  let(:bucket) { StringIO.new }

  it "has a executable" do
    process = CommandExec::Process.new(logger: Logger.new(bucket))
    process.executable = '/bin/sh'
    expect(process.executable).to eq('/bin/sh')
  end

  it "opens a log file" do
    process = CommandExec::Process.new(logger: Logger.new(bucket))
    tmp_file = create_tmp_file_with('process.log' , 'this is content' )
    process.log_file = tmp_file

    expect(process.log_file).to eq(['this is content'])
  end

  it "accepts nil as filename" do
    process = CommandExec::Process.new(logger: Logger.new(bucket))
    process.log_file = nil

    expect(process.log_file).to eq([])
  end

  it "goes on with a warning, if log file doesn't exists" do
    file = '/tmp/test1234.txt'
    process = CommandExec::Process.new(logger: Logger.new(bucket))
    tmp_file = create_tmp_file_with('process.log' , 'this is content' )
    process.log_file = file
    process.log_file

    expect(bucket.string[file]).to_not eq(nil)
  end

  it "takes stdout" do
    process = CommandExec::Process.new(logger: Logger.new(bucket)) 
    process.stdout = 'content'
    expect(process.stdout).to eq(['content'])

    process = CommandExec::Process.new(logger: Logger.new(bucket)) 
    process.stdout = ['content']
    expect(process.stdout).to eq(['content'])
  end

  it "takes stderr" do
    process = CommandExec::Process.new(logger: Logger.new(bucket)) 
    process.stderr = 'content'
    expect(process.stderr).to eq(['content'])

    process = CommandExec::Process.new(logger: Logger.new(bucket)) 
    process.stderr = ['content']
    expect(process.stderr).to eq(['content'])
  end

  it "takes a status" do
    process = CommandExec::Process.new(logger: Logger.new(bucket)) 
    process.status = :failed
    expect(process.status).to eq(:failed)

    process = CommandExec::Process.new(logger: Logger.new(bucket)) 
    process.status = :success
    expect(process.status).to eq(:success)

    process = CommandExec::Process.new(logger: Logger.new(bucket)) 
    process.status = :unknown
    expect(process.status).to eq(:failed)
  end

  it "takes a reason for a failure" do
    process = CommandExec::Process.new(logger: Logger.new(bucket)) 
    process.reason_for_failure = 'this is an error msg'
    expect(process.reason_for_failure).to eq(['this is an error msg'])
  end

  it "takes a return code" do
    process = CommandExec::Process.new(logger: Logger.new(bucket)) 
    process.return_code = 1
    expect(process.return_code).to eq(1)
  end

  it "returns a hash" do
    #process.stdout

  end

  it "returns an array" do

  end
end
