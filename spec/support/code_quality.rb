unless ENV['CI'] == 'true'
  require 'pry'
  require 'debugger'
  require 'ap'
end

unless ENV['CI'] == 'true'
  require 'simplecov'
  SimpleCov.start
end
