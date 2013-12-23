# encoding: utf-8

describe RuntimeLogger do
  context '#start' do
    it 'sets start time of command' do
      runtime = RuntimeLogger.new
      runtime.start
      expect(runtime.start_time.to_s).to eq(Time.now.to_s)
    end
  end

  context '#end' do
    it 'sets end time of command' do
      runtime = RuntimeLogger.new
      runtime.stop
      expect(runtime.stop_time.to_s).to eq(Time.now.to_s)
    end
  end

  context '#duration' do
    it 'calculations the duration of command' do
      runtime = RuntimeLogger.new
      runtime.start
      sleep(1)
      runtime.stop
      expect(runtime.duration.to_i).to eq(1)
    end
  end
end
