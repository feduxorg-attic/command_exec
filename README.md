command-exec(1) -- execute shell commands with ease
===================================================

[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/maxmeyer/command_exec)
[![Build Status](https://secure.travis-ci.org/maxmeyer/command_exec.png)](http://travis-ci.org/maxmeyer/command_exec)


## <a name="introduction">Introduction</a>

### Description

The name of the library is `command_exec`. It's helps you running programs and
check if the run was successful. It supports a vast amount of options you find
in the one of the following sections [usage](#usage).

`Example`:

```ruby
require 'command_exec'

# command has to be in $PATH
command = CommandExec::Command.new( :echo , :parameter => 'hello world' )
command.run
p command.result
```

### Target "Group"

If you need a library to execute programs which do a job and then terminate,
`command_exec` is your friend. 

If you need a library which supports error detection based on STDOUT, STDERR,
RETURN CODE and/or LOG FILE `command_exec` is the right choice.

### Limitations

The programs should NOT produce gigabytes of output (STDOUT, STDERR, LOG FILE)
to search for errors. 

### Structure of documentation

<table>
  <tr>
    <th>Section</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>Introduction</td>
    <td>Metainformation</td>
  </tr>
  <tr>
    <td>Usage</td>
    <td>How to use the library</td>
  </tr>
  <tr>
    <td>Options</td>
    <td>Which options are available to parametrize the library</td>
  </tr>
  <tr>
    <td>HowTo</td>
    <td>How to do ... with library</td>
  </tr>
  <tr>
    <td>Further reading</td>
    <td>Other helpful information</td>
  </tr>
</table>

## <a name="usage">Usage<a/>

### Install gem

Install the `command_exec`-gem via `rubygems` or whatever package manager (e.g. `bundler`) you like
to use.

```bash
gem install command_exec
```

### Include library

To include the library in your code, you could use this code snippet.

```ruby
require 'command_exec'
```
### Run command

There are two forms to execute a program. You could either use the long or the
short form. In both cases a `CommandExec::Command`-object will be returned.

```ruby
command = CommandExec::Command.new( :echo , :parameter => 'hello world' )
command.run
p command.result
```

```ruby
command = CommandExec::Command.execute( :echo , :parameter => 'hello world' )
p command.result
```

### Result of command execution

That `result`-object can be used to inspect the result of the command execution. It
supports several different methods, but only some are from interest for
external use. If you want a full list, please see the API-documentation at
[rdoc.info](http://www.rdoc.info/github/maxmeyer/command_exec/CommandExec/Process).

```ruby
result = command.result

# which executable was run
result.executable

# !!content!! of log file
result.log_file

# pid unter which the command was run
result.pid

#if failed, why
result.reason_for_failure

#return code of command
result.return_code

#status of command execution
result.status

#content of stderr
result.stderr

#content of stdout
result.stdout
```

### Serialize result of command execution

There are some methods which need a little more explanation. Those methods
return a string representation of the result. 

```ruby
#return an array of lines
result.to_a

#return a hash
result.to_h

#serialize data to json
result.to_json

#serialize data to string
result.to_s

#serialize data to xml
result.to_xml

#serialize data to yaml
result.to_yaml
```

One can tell those methods which data should be returned. There are different
fields available:

<table>
  <tr>
    <th>Field</th>
    <th>Symbol</th>
  </tr>
  <tr>
    <td>Status</td>
    <td>:status</td>
  </tr>
  <tr>
    <td>Return code</td>
    <td>:return_code</td>
  </tr>
  <tr>
    <td>STDERR</td>
    <td>:stderr</td>
  </tr>
  <tr>
    <td>STDOUT</td>
    <td>:stdout</td>
  </tr>
  <tr>
    <td>Log file</td>
    <td>:log_file</td>
  </tr>
  <tr>
    <td>Process identitfier (PID)</td>
    <td>:pid</td>
  </tr>
  <tr>
    <td>Reason for failure</td>
    <td>reason_for_failure</td>
  </tr>
</table>

Now, some small examples:

```ruby
#result.<method>(field1,field2, ... , fieldn)
#result.<method>([field1,field2, ... , fieldn])

#all fields
result.to_a

#stderr and stdout only
result.to_a(:stderr, :stdout)

#stderr and stdout only (parameters given as a single array)
result.to_a([:stderr, :stdout])
```

## Options

### Logging 

`command_exec` makes use of the Ruby `Logger`-class. If you would like to use
another class/gem, nevermind, but it has to be compatible with the `Logger`-API.

To make it easier for you, `command_exec` provides a `:logger` option. It
defaults to `Logger.new($stderr)`. 

```ruby
command = CommandExec::Command.execute( :echo , 
                                        :parameter => 'hello world',
                                        :logger => Logger.new($stderr),
                                        )
p command.result
```

If you prefer more or less information you can make use of the
`:lib_log_level`-option. With one exception, those log levels are the same like in
the `Logger`-class. Additionally you can use `:silent` to suppress all output
of the library, if you use the `open3` and not the `system` runner. If you
choose to use the system runner, STDOUT from the command won't be captured.


<table>
 <tr>
  <td><strong>Option value</strong></td>
  <td><strong>Logger loglevel</strong></td>
 </tr>
 <tr>
  <td>:debug</td>
  <td>Logger::DEBUG</td>
 </tr>
 <tr>
  <td>:info</td>
  <td>Logger::INFO</td>
 </tr>
 <tr>
  <td>:warn</td>
  <td>Logger::WARN</td>
 </tr>
 <tr>
  <td>:error</td>
  <td>Logger::ERROR</td>
 </tr>
 <tr>
  <td>:fatal</td>
  <td>Logger::FATAL</td>
 </tr>
 <tr>
  <td>:unknown</td>
  <td>Logger::UNKNOWN</td>
 </tr>
 <tr>
 <td>:silent</td>
  <td>no output (log device is set to nil)</td>
 </tr>
</table>


```ruby
command = CommandExec::Command.execute( :echo , 
                                        :parameter => 'hello world' ,
                                        :lib_log_level => :debug,
                                        )
p command.result
```

### Command options and parameter

The next two options (command options and command parameters) are very similar.
Both will be used to build the command which should be executed. The main
difference is the position of given string in the command string.

```
<command> <options> <parameter>
```

So, if you don't want to use the `options`- and/or the `parameter`-option, you
don't need to do it. But may be there are situations, where you would like to
be as concise as possible.


Recommended:

```ruby
command = CommandExec::Command.execute( :ls , 
                                        :options => '-al',
                                        :parameter => '/bin',
                                        :lib_log_level => :debug,
                                        )
p command.result
```

But also valid:

```ruby
command = CommandExec::Command.execute( :ls , 
                                        :options => '-al /bin',
                                        :lib_log_level => :debug,
                                        )
p command.result
```

Or:

```ruby
command = CommandExec::Command.execute( :ls , 
                                        :parameter => '-al /bin',
                                        :lib_log_level => :debug,
                                        )
p command.result
```

### Command parameters
:parameter => '',

If you would like 

### Working directory

:working_directory => Dir.pwd,

### Command log file
:cmd_log_file => '',

### Command search path

:search_paths => ENV['PATH'].split(':'),

### Error detection

:error_detection_on => [:return_code],
:error_indicators => {
  :allowed_return_code => [0],
  :forbidden_return_code => [],
  #
  :allowed_words_in_stderr => [],
  :forbidden_words_in_stderr => [],
  #
  :allowed_words_in_stdout => [],
  :forbidden_words_in_stdout => [],
  #
  :allowed_words_in_log_file => [],
  :forbidden_words_in_log_file => [],
},

### Error reaction

:on_error_do => :return_process_information,

### Runner

:run_via => :open3,


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
