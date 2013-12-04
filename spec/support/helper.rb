require 'active_support/core_ext/numeric/time'
require 'stringio'
require 'tempfile'
require 'fedux_org/stdlib/filesystem'

include FeduxOrg::Stdlib::Filesystem

def root_directory
  CommandExec.root_directory
end
