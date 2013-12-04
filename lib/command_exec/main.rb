module CommandExec

  @logger = FeduxOrg::Stdlib::Logging::Logger.new

  class << self
    attr_accessor :logger, :search_paths

    search_paths = ENV['PATH'].split(/:/)

    def root_directory
      File.expand_path( '../../../', __FILE__ )
    end
  end
  
end
