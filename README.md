# command-exec -- execute shell commands with ease

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

### <a name="result_of_command_execution">Result of command execution</a>

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

## Extended usage

There are multiple ways to tell `command_exec` about a command:

### Search command in PATH

If the first parameter of `run` and `execute` is a `Symbol` the library will
search for the command in the paths given in the $PATH-shell-variable.

```ruby
command = CommandExec::Command.execute( :echo , 
                                        :parameter => 'hello world',
                                        )
p command.result
```

### Path to command

If you prefer to use a full qualified path, this is possible as well.

```ruby
command = CommandExec::Command.execute( '/bin/echo' , 
                                        :parameter => 'hello world',
                                        )
p command.result
```

It also supports relative paths. But be aware to tell the library the correct
one. The base path for relative ones is the working directory of the *library*,
not the working directory of the command (see section "[Working
directory](#working_directory)" about that).


```ruby
Dir.chdir('/tmp') do
  command = CommandExec::Command.execute( '../bin/echo' , 
                                          :parameter => 'hello world',
                                          :logger => Logger.new($stderr)
                                          )
  p command.result
end
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
                                        )
p command.result
```

But also valid:

```ruby
command = CommandExec::Command.execute( :ls , 
                                        :options => '-al /bin',
                                        )
p command.result
```

Or:

```ruby
command = CommandExec::Command.execute( :ls , 
                                        :parameter => '-al /bin',
                                        )
p command.result
```

Please check if you use single or double quotes correctly! `command_exec` takes
the parameters and options as given. That's why

```ruby
#will succeed
#see debug output for reason
command = CommandExec::Command.execute( :echo , 
                                        :options => '-e',
                                        :parameter => "\"Thats a string\n with a newline\"",
                                        :lib_log_level => :debug,
                                        )
p command.result
```

isn't the same like

```ruby
#will fail
#see debug output for reason
command = CommandExec::Command.execute( :echo , 
                                        :options => '-e',
                                        :parameter => "Thats a string\n with a newline",
                                        :lib_log_level => :debug,
                                        )
p command.result
```

### <a name="log_file">Command log file</a>

If the command creates a log file, you can tell `command_exec` about that file
via the `:log_file`-option. Honestly, this option only makes sense if you
configure `command_exec`to search for errors in the file (please see the
chapter about [Error detection](#error_detection) for further information about
that).

```ruby
command = CommandExec::Command.execute( :ls , 
                                        :options => '-al',
                                        :log_file => '/path/to/log_file',
                                        )
p command.result
```

### Command search path

If you need to change the paths where a command can be found, you could use the
`:search_path`-option. It defaults to those paths found in $PATH.

It supports multiple values as `Array`:

```ruby
command = CommandExec::Command.execute( :ls , 
                                        :options => '-al',
                                        :search_paths => [ '/bin' ],
                                        )
p command.result
```

Or single values as `String`:

```ruby
command = CommandExec::Command.execute( :ls , 
                                        :options => '-al',
                                        :search_paths => '/bin',
                                        )
p command.result
```

### <a name="error_detection">Error detection</a>

`command_exec` is capable of searching for errors. To enable error detection
you need to activate it via the `:error_detection_on`-option. It supports error
detection on:

<table>
 <tr>
  <td><strong>Search in...</strong></td>
  <td><strong>Symbol</strong></td>
 </tr>
 <tr>
  <td>Return code</td>
  <td>:return_code</td>
 </tr>
 <tr>
  <td>STDOUT</td>
  <td>:stdout</td>
 </tr>
 <tr>
  <td>STDERR</td>
  <td>:stderr</td>
 </tr>
 <tr>
  <td>Log file</td>
  <td>:log_file</td>
 </tr>
</table>

But you need to provide information, what item indicates an error.

<table>
 <tr>
  <td><strong>Indicator for...</strong></td>
  <td><strong>Options</strong></td>
  <td><strong>Type</strong></td>
 </tr>
 <tr>
  <td>Return code</td>
  <td>
  :allowed_return_code<br/>
  :forbidden_return_code
  </td>
  <td>
  Array
  </td>
 </tr>
 <tr>
  <td>STDERR</td>
  <td>
  :allowed_words_in_stderr<br/>
  :forbidden_words_in_stderr
  </td>
  <td>
  Array
  </td>
 </tr>
 <tr>
  <td>STDOUT</td>
  <td>
  :allowed_words_in_stdout<br/>
  :forbidden_words_in_stdout
  </td>
  <td>
  Array
  </td>
 </tr>
 <tr>
  <td>Log file</td>
  <td>
  :allowed_words_in_log_file<br/>
  :forbidden_words_in_log_file
  </td>
  <td>
  Array
  </td>
 </tr>
</table>

*Return code*

If the command returns helpful return codes, those can be used to check if an
error occured. You can tell `command_exec` about allowed or forbidden return
codes.


```ruby
#All error codes except `0` will be detected as an error.
command = CommandExec::Command.execute( :false , 
                                        :error_detection_on => [:return_code],
                                        :error_indicators => {
                                          :allowed_return_code => [0],
                                        },
                                        )
p command.result

#If the command exits with a return code of `1`, this will be detected as an
#error.
command = CommandExec::Command.execute( :false , 
                                        :error_detection_on => [:return_code],
                                        :error_indicators => {
                                          :forbidden_return_code => [1],
                                        },
                                        )
p command.result
```

In the case of the detection of errors `command_exec`defaults to:

```ruby
:error_detection_on => [:return_code],
:allowed_return_code => [0],
```

*STDOUT*

`command_exec` can search for errors in STDOUT. To enable this functionality,
you need to set the `:error_detection_on`-option on ':stdout'. Furthermore you
need to tell the library, what strings are error indicators
(`forbidden_words_in_stdout`). If there are some strings which contain the
error string(s), but are no errors, you need to use the
`allowed_words_in_stdout`-option. The same is true, if the allowed word is in
the same line.

```ruby
#Simple error search
#will fail
command = CommandExec::Command.execute( :echo , 
                                        :options => '-e',
                                        :parameter => "\"wow, a test. That's great.\nBut an error occured in this line\"",
                                        :error_detection_on => [:stdout],
                                        :error_indicators => {
                                          :forbidden_words_in_stdout => %w{ error }
                                        },
                                        )
p command.result

#error indicator in string, which is no error
#will succeed
command = CommandExec::Command.execute( :echo , 
                                        :options => '-e',
                                        :parameter => "\"wow, a test. That's great.\nBut no error occured in this line\"",
                                        :error_detection_on => [:stdout],
                                        :error_indicators => {
                                          :forbidden_words_in_stdout => %w{ error },
                                          :allowed_words_in_stdout => ["no error occured"] , 
                                        },
                                        )
p command.result

#error indicator in same line, which is no error
#will succeed
command = CommandExec::Command.execute( :echo , 
                                        :options => '-e',
                                        :parameter => "\"wow, a test. That's great.\nBut no error occured in this line because of some other string\"",
                                        :error_detection_on => [:stdout],
                                        :error_indicators => {
                                          :forbidden_words_in_stdout => %w{ error },
                                          :allowed_words_in_stdout => ["some other string"] , 
                                        },
                                        )
p command.result
```

*STDERR*

The same is true for STDERR. You need to activate the error detection via
`:error_detection_on => [:stderr]`. The error indicators can be given via
`:forbidden_words_in_stderr => %w{ error }` and `:allowed_words_in_stdout =>
["some other string"]`.

```ruby
#will fail
command = CommandExec::Command.execute( :echo , 
                                        :options => '-e',
                                        :parameter => "\"wow, a test. That's great.\nBut an error occured in this line\" >&2",
                                        :error_detection_on => [:stderr],
                                        :error_indicators => {
                                          :forbidden_words_in_stderr => %w{ error },
                                        },
                                        )
p command.result
```

*LOG FILE*

To search for errors in the log file a command created during execution, you
need to provide the information where `command_exec` finds the log file (see
section [Command Log file](#log_file)).

The options are very similar to those for STDERR and STDOUT: To activate error
detection for log files use `:error_detection_on => [:log_file]`. The error
indicators can be given via `:forbidden_words_in_log_file => %w{ error }` and
`:allowed_words_in_log_file => ["some other string"]`.

```ruby
File.open('/tmp/test.log', 'w') do |f|
  f.write "wow, a test. That's great.\nBut an error occured in this line"
end

#will fail
command = CommandExec::Command.execute( :echo , 
                                        :error_detection_on => [:log_file],
                                        :log_file => '/tmp/test.log',
                                        :error_indicators => {
                                          :forbidden_words_in_log_file => %w{ error },
                                        },
                                        )
p command.result
```

### <a name="working_directory">Working directory</a>

To change the working directory for the command you can use the `:working_directory`-option.

```ruby
command = CommandExec::Command.execute( :ls , 
                                        :options => '-al',
                                        :working_directory => '/tmp',
                                        )
p command.result
```

### Error reaction

If an error occured, `command_exec` can raise an exception, 'throw' an error or
do nothing at all. Besides the configured option, on every run it returns the
  result for the run (see [Result of command
  execution](#result_of_command_execution) for more details).

*Raise an exception aka error*

If an error occured during command execution, you can tell `command_exec` to
raise an exception.

```ruby
begin
  command = CommandExec::Command.execute( :false , 
                                          :on_error_do => :raise_error,
                                        )
rescue CommandExec::Exceptions::CommandExecutionFailed => e
  puts e.message
end
```

*Throw error*

If you prefer not to use execptions, you can use ruby's
`throw`-`catch`-mechanism.

```ruby
catch :command_execution_failed do 
  command = CommandExec::Command.execute( :false , 
                                          :on_error_do => :throw_error,
                                        )
end
```

### Runner

Today there are two runners available: `:open3` and `system`. Use the first one
if you want `:stdout` and `:stderr` to be captured and searched for errors. If
you're only interested in the `:return_code` you could use the
`:system`-runner. Please be aware, that using the `system`-runner + error
detection on `stdout`, `stderr` is not working as you might expect.

```ruby
#will fail
command = CommandExec::Command.execute( :echo , 
                                        :options => '-e',
                                        :parameter => "\"wow, a test. That's great.\nBut an error occured in this line\"",
                                        :error_detection_on => [:stdout],
                                        :error_indicators => {
                                          :forbidden_words_in_stdout => %w{ error }
                                        },
                                        :run_via => :open3,
                                        )
p command.result

#will succeed, because stdout was not caputured
command = CommandExec::Command.execute( :echo , 
                                        :options => '-e',
                                        :parameter => "\"wow, a test. That's great.\nBut an error occured in this line\"",
                                        :error_detection_on => [:stdout],
                                        :error_indicators => {
                                          :forbidden_words_in_stdout => %w{ error }
                                        },
                                        :run_via => :system,
                                        )
p command.result
```
## HowTo

TBD

## Further Reading

* API-documentation: http://rdoc.info/github/maxmeyer/command_exec/frames

## Dependencies

Please see the gemspec for runtime dependencies and the 'Gemfile' for
development dependencies.

## Todo

Please see TODO.md for enhancements which are planned for implementation.

## Development

1. Fork it
2. Create your remote (`git remote add <your_remote_repo> <path_to_repo>`)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push <your_remote_repo> my-new-feature`)
5. Create new Pull Request

The API-documentation can be found at
http://rdoc.info/github/maxmeyer/command_exec/frames

Please see 'http://git-scm.com/book' first if you have further questions about
`git`.

## Copyright

(c) 2012-, Max Meyer

## License

Please see LICENSE.md for license text.
