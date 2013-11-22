module CommandExec

  @logger = FeduxOrg::Stdlib::Logging::Logger.new

  class << self
    attr_accessor :logger, :search_paths

    search_paths = ENV['PATH'].split(/:/)
  end
  
end
