module CommandExec

  @logger = FeduxOrg::Stdlib::Logging::Logger.new

  class << self
    def logger
      @logger
    end

    def logger=( l )
      @logger = l
    end
  end
  
end
