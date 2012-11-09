# 0.2.0

This release is a major rewrite of the library. Please keep in mind it is still
under very active development and till 1.0.0 the API can change at any time.
Though I'm quite satisfied with the api and will try to add things only.

* *TREATMENT OF COMMAND NAMES*: 

Now only commands given as symbols will be searched in search path. Which can
be set as well now. If a string is given, it will be searched in the current
working directory. Furthermore the resolver was refactored. It is now a ruby
only solution.

* *TEST SUITE*:

Improved test suite. Added more tests and add `simplecov` for coverage check.

* *WORKING DIRECTORY*:

No side effects any more when using a working directory. This might have had an
effect on your library if you start your script from directory 'A', but want the 
command to be run in directory 'B'. After running the command with `CommandExec`
the current working directory of your script was changed as well. This is fixed
now.

* *LOGGING*:

Now you have the possibility to change the log level of `CommandExec`. If you
choose one of `:silent`, `:unknown`, `:fatal`, `:error`, `:warn`, `:info` and
`:debug`. All possibilities map to their `Logger`-counterpart, so please see
the ruby logger documentation on the net (google for ruby logger). The only
exception is `:silent`. Choosing this option `CommandExec` will not output
anything.

* *VERSIONING*:

This gem now uses semvar versioning scheme. See www.semvar.org for more information.

* *RESULT OF COMMAND EXECUTION*:

Now it's possible that you get the result of the command execution in different formats:
  * Array
  * Hash
  * JSON-String
  * Simple String
  * XML-String
  * YAML-String

* *ERROR DETECTION*:

As part of the new interface there are methods put in place to detect errors
during command execution: Return code, STDERR, STDOUT and log file.

* *REACTION ON ERRORS*:

If an error happend, you can raise an exception, throw an error or ask
`CommandExec`to do nothing at all.

* *COMMAND RUNNER*

The new version switches from `POpen4` to `Open3` as default runner.
Furthermore `system`-call is also supported.
