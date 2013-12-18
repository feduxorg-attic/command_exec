require 'fedux_org/stdlib/filesystem'

RSpec.configure do |c|
  c.before(:all) do
    include FeduxOrg::Stdlib::Filesystem

    def root_directory
      CommandExec.root_directory
    end

    def in_directory(directory, &block)
      Dir.chdir(directory)do
        block.call(directory)
      end
    end

    alias_method :switch_to_working_directory, :in_working_directory 
  end
end
