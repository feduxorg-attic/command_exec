# encoding: utf-8
$LOAD_PATH << File.expand_path('../lib', File.dirname(__FILE__))

require_relative 'support/code_quality'

Dir.glob(File.expand_path('../support/*.rb', __FILE__)).each {|f| require f} if Dir.exists? File.expand_path('../support', __FILE__)
