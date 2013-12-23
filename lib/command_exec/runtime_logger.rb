# encoding: utf-8
module CommandExec
  class RuntimeLogger
    attr_reader :start_time, :stop_time

    # Determine start time
    def start
      @start_time = Time.now
    end

    # Determine stop time
    def stop
      @stop_time = Time.now
    end

    # Duration
    def duration
      @stop_time - @start_time
    end
  end
end
