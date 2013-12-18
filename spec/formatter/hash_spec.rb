#encoding: utf-8

require 'spec_helper'

describe Formatter::Hash do

  before :each do
    @formatter = Formatter::Hash.new
  end

  context :private_api do

    it 'prepares output for all fields (default)' do
      @formatter.stderr('output of stderr')
      expect(@formatter.send(:prepare_output)).to eq({ :status=>[], :pid => [], :return_code=>[], :stderr=>['output of stderr'], :stdout=>[], :log_file=>[], :reason_for_failure=>[], :executable => [], :start_time => [], :end_time => [] })
    end

    it 'prepares output for given fields' do
      @formatter.stderr('output of stderr')
      expect(@formatter.send(:prepare_output, [:stderr])).to eq({ :stderr=>['output of stderr'] })
    end

  end

  context :public_api do

    it 'outputs stderr with header' do
      expect(@formatter.stderr('output of stderr')).to eq(['output of stderr'])
    end

    it 'supports arrays as well' do
      expect(@formatter.stderr(['output of stderr'])).to eq(['output of stderr'])
    end

    it 'outputs multiple values if called multiple times (but only with one header)' do
      2.times do
        @formatter.stderr(['output of stderr'])
      end
      expect(@formatter.output(:stderr)).to eq(stderr: ['output of stderr', 'output of stderr'])
    end

    it 'outputs stdout' do
      expect(@formatter.stdout('output of stdout')).to eq(['output of stdout'])
    end

    it 'outputs log file' do
      expect(@formatter.log_file('output of log file')).to eq(['output of log file'])
    end

    it 'outputs return code' do
      expect(@formatter.return_code('output of return code')).to eq(['output of return code'])
    end

    it 'outputs status' do
      expect(@formatter.status(:failed)).to eq(['FAILED'])
      expect(@formatter.status(:success)).to eq(['OK'])
      expect(@formatter.status(:unknown)).to eq(['FAILED'])
    end

    it 'outputs status as single value (no data is appended)' do
      @formatter.status(:success)
      @formatter.status(:failed)
      expect(@formatter.output(:status)).to eq(status: ['FAILED'])
    end

    it 'supports status as string as well' do
      expect(@formatter.status('failed')).to eq(['FAILED'])
      expect(@formatter.status('success')).to eq(['OK'])
    end

    it 'accepts a reason for a failure' do
      expect(@formatter.reason_for_failure('error in stdout found')).to eq(['error in stdout found'])
    end

    it 'output only wanted values' do
      @formatter.stderr(['output of stderr'])
      @formatter.stdout('output of stdout')
      @formatter.log_file('output of log file')
      @formatter.return_code('output of return code')
      @formatter.status(:failed)
      @formatter.pid(4711)
      @formatter.reason_for_failure('great an error occured')
      @formatter.executable('/usr/bin/true')

      expect(@formatter.output(:stderr)).to eq(stderr: ['output of stderr'])
      expect(@formatter.output).to eq(status: ['FAILED'],
                                      return_code: ['output of return code'],
                                      stderr: ['output of stderr'],
                                      stdout: ['output of stdout'],
                                      log_file: ['output of log file'],
                                      pid: ['4711'],
                                      reason_for_failure: ['great an error occured'],
                                      executable: ['/usr/bin/true'],
                                      start_time: [],
                                      end_time: [],
                                     )
      expect(@formatter.output(:stdout, :stderr)).to eq(
                                                       stdout: ['output of stdout'],
                                                       stderr: ['output of stderr'],
                                                      )
    end

    it 'output only wanted values (given as array)' do
      @formatter.stderr(['output of stderr'])
      @formatter.stdout('output of stdout')
      @formatter.log_file('output of log file')
      @formatter.return_code('output of return code')
      @formatter.status(:failed)
      @formatter.executable('/usr/bin/true')

      expect(@formatter.output([:stdout, :stderr])).to eq(
                                                       stdout: ['output of stdout'],
                                                       stderr: ['output of stderr'],
                                                      )
    end
  end
end
