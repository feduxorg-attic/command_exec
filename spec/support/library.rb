require 'command_exec'

RSpec.configure do |c|
  c.before(:all) do
    include CommandExec
    include CommandExec::Exceptions
  end
end
