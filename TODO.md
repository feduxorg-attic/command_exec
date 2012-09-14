* Check if attr_accessor or attr_reader is better in command.rb
* alias run_successful? to success?
* refactor lib interface
```ruby
#options
  on_error: [:do_nothing, :return_status, :raise_exception ]

#raise_exception with serialized status object
require 'json'
raise ExecuteCommandFailed , JSON.dump status 
```
* Add tests for search command
* Add support for formatters of output
* Refactor POpen4 -> Open3
* Refactor working directory -> use Open3 option
* Add reason for failure: :stdin, :stdout, :exitstatus, ...
