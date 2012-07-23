#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'yard'
require 'rubygems/package_task'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', 'README.md', 'LICENCE.md']
  t.options = ['--output-dir=doc/yard', '--markup-provider=redcarpet', '--markup=markdown' ]
end

task :terminal do
  sh "script/terminal"
end

task :term => :terminal
task :t => :terminal

namespace :version do
  version_file = Dir.glob('lib/**/version.rb').first

  task :bump do

    new_version = ENV['VERSION']

    version_string = %Q{ module DataUri
        VERSION = '#{new_version}'
    end}

    File.open(version_file, "w") do |f|
      f.write version_string.strip_heredoc
    end

    sh "git add #{version_file}" 
    sh "git commit -m 'version bump to #{new_version}'" 
    sh "git tag data_uri-#{new_version}" 
  end

  task :show do
    raw_version = File.open(version_file, "r").readlines.grep(/VERSION/).first

    if raw_version
      version = raw_version.chomp.match(/VERSION\s+=\s+["']([^'"]+)["']/) { $1 }
      puts version
    else
      warn "Could not parse version file \"#{version_file}\""
    end

  end
end
