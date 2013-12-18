require 'fedux_org/stdlib/environment'

RSpec.configure do |c|
  c.before(:all) do
    include FeduxOrg::Stdlib::Environment
    alias_method :isolated_environment, :with_environment 
  end
end
