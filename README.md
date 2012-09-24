command-exec(1) -- execute shell commands with ease
===================================================

[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/maxmeyer/command_exec)
[![Build Status](https://secure.travis-ci.org/maxmeyer/command_exec.png)](http://travis-ci.org/maxmeyer/command_exec)


## Description

This gem brings command execution via POpen4 with all the bells and whistles.


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
```

## Options

* `:logger`: Logger for output of information

```ruby
command = CommandExec::Command.new(
  'command',
  :logger => Logger.new($stderr),
}
command.run
```

* `:options`: Commandline options for executed command

```ruby
command = CommandExec::Command.new(
  'command',
  :options => '--command options',
}
command.run
```

* `error_keywords`: Keywords which indicate error(s)

Are there any keywords in stdout of the command which should be executed, which
indicate errors?

```ruby
command = CommandExec::Command.new(
  'command',
  :error_keywords => ['key words in', 'stdout with indicate errors' ],
}
command.run
```

* `:working_directory`: Change working directory of command 

Change working directory to given one before command execution.

```ruby
command = CommandExec::Command.new(
  'command',
  :working_directory => 'working/directory/where/the/command/should/be/executed/in',
}
command.run
```

* `logfile`: Logfile of command

The first 30 lines of the command-logfile will be output by logger if an error
occured. 

```ruby
command = CommandExec::Command.new(
  'command',
  :logfile => 'path/to/logfile.log',
}
command.run
```

* `:log_level`: 

What should be put to logger? Available choices are :debug, :info, :warn,
:error, :fatal, :unkonwn, :silent. If you choose :silent nothing will be
output. If you choose open3 as runner this is also true for stdout/stderr of
the executed programms. this is not true for the system runner.


```ruby
command = CommandExec::Command.new(
  'command',
  :logfile => 'path/to/logfile.log',
  :log_level => :debug
}
command.run
```
## Error detection

Errors can be detected in:
* STDERR
* STDOUT
* LOGFILE

Furthermore `command_exec` looks at the return code of your command.

## Reaction on error

If an error occured, `command_exec` supports three different ways to react upon
an error:
* do nothing
* throw an error
* raise an exception


```ruby
```
## Output

After execute the command you get the following output. Today it's not possible
to suppress that output, but it's on the roadmap.

Order of fields
Available fields

### Successfull 

```
<timestamp> command: OK
```

### Failed with STDERR set

```
<timestamp> command: FAILED
================== LOGFILE ==================
[...]
================== STDOUT ==================
[...]
================== STDERR ==================
[...]
```

### Failed with string in STDOUT indicating an error

```
<timestamp> command: FAILED
================== STDOUT ==================
```

## Dependencies

Please see the gemspec for runtime dependencies and the 'Gemfile' for
development dependencies.

## Todo

Please see TODO.md for enhancements which are planned for implementation.

## Copyright

(c) 2012-, Max Meyer

## License

Please see LICENSE.md for license text.
