#encoding: utf-8
$LOAD_PATH << File.expand_path('../lib' , File.dirname(__FILE__))

Dir.glob( File.expand_path( '../support/*.rb', __FILE__ ) ).each { |f| require f } if Dir.exists? File.expand_path( '../support', __FILE__ )

require 'command_exec'
require 'command_exec/spec_helper_module'

include CommandExec
include CommandExec::Exceptions
