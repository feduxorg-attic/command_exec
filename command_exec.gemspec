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
  s.add_runtime_dependency 'smart_colored'
  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'xml-simple'
  s.add_runtime_dependency 'the_array_comparator'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'fuubar'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'github-markup'
  s.add_development_dependency 'tmrb'
  s.add_development_dependency 'travis-lint'
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'activesupport'
end
