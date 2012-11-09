#encoding: utf-8

$LOAD_PATH << File.expand_path('../lib' , File.dirname(__FILE__))

unless ENV['TRAVIS_CI'] == 'true'
  require 'pry'
  require 'debugger'
  require 'ap'
end

require 'stringio'
require 'tempfile'

unless ENV['TRAVIS_CI'] == 'true'
  require 'simplecov'
  SimpleCov.start
end

require 'command_exec'
require 'command_exec/spec_helper_module'
require 'active_support/core_ext/numeric/time'

include CommandExec
include CommandExec::Exceptions

RSpec.configure do |c|
  c.include CommandExec::SpecHelper
  c.treat_symbols_as_metadata_keys_with_true_values = true
  #c.filter_run_including :focus => true
end

#ENV['PATH'] = '/bin'
