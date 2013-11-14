unless ENV['TRAVIS_CI'] == 'true'
  require 'pry'
  require 'debugger'
  require 'ap'
end

unless ENV['TRAVIS_CI'] == 'true'
  require 'simplecov'
  SimpleCov.start
end
