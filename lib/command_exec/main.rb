# encoding: utf-8
module CommandExec
  @logger       = FeduxOrg::Stdlib::Logging::Logger.new
  @search_paths = nil

  class << self
    attr_accessor :logger, :search_paths

    def root_directory
      File.expand_path( '../../../', __FILE__ )
    end
  end
end
