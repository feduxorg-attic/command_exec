command-exec(1) -- execute shell commands with ease
===================================================

## Description

This gem brings bells and whistles to command execution via POpen4.

## Usage

```ruby
require 'command_exec'

#long form
command = CommandExec::Command.new( 'command' )
command.run

#short form
command = CommandExec::Command.execute( 'command')

#full path to commadn
command = CommandExec::Command.execute( 'path/to/command')

# available options
command = CommandExec::Command.new(
  'command',
  :logger => Logger.new($stderr),
  :options => '--command options',
  :parameter => 'command parameter',
  :error_keywords => ['key words in', 'stdout with indicate errors' ],
  :working_directory => 'working/directory/where/the/command/should/be/executed/in',
  :logfile => 'path/to/logfile.log',
  :debug => false,
  )
command.run
```

## Output

After execute the command you get the following output. Today it's not possible
to suppress that output, but it's on the roadmap.

### Successfull 

<timestamp> command: OK

### Failed with STDERR set

<timestamp> command: FAILED
================== LOGFILE ==================
[...]
================== STDOUT ==================
[...]
================== STDERR ==================
[...]

### Failed with string in STDOUT indicating an error

<timestamp> command: FAILED
================== STDOUT ==================

## Dependencies

Please see the gemspec for runtime dependencies and the 'Gemfile' for
development dependencies.

## Todo

Please see TODO.md for enhancements which are planned for implementation.

## Copyright

(c) 2012-, Max Meyer

## License

Please see LICENSE.md for license text.
