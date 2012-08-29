# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "command_exec/version"

Gem::Specification.new do |s|
  s.name        = "command_exec"
  s.version     = CommandExec::VERSION
  s.authors     = ["Max Meyer"]
  s.email       = ["dev@fedux.org"]
  s.homepage    = ""
  s.summary     = %q{Helper gem to exectue arbitrary shell commands}
  s.description = %q{This adds bells and whistles to ease shell command execution}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # specify any dependencies here; for example:
  s.add_runtime_dependency 'POpen4'
  s.add_runtime_dependency 'colored'
  s.add_runtime_dependency 'activesupport'
end
