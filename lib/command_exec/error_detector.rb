#encoding: utf-8
module CommandExec

  #detect errors
  class ErrorDetector

    def initialize(comparator=TheArrayComparator::Comparator.new)
      @comparator = comparator
    end

    def check_for( *args )
      @comparator.add_check( *args )
    end

    def found_error?
      not @comparator.success?
    end

    def failed_sample
      @comparator.result.failed_sample
    end

  end
end
