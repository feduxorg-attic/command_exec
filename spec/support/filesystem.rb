require 'fedux_org/stdlib/filesystem'
include FeduxOrg::Stdlib::Filesystem

def root_directory
  CommandExec.root_directory
end