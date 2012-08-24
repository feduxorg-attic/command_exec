* Check if attr_accessor or attr_reader is better in command.rb
* alias run_successful? to success?
* refactor lib interface
```ruby
#options
  error_detection_on: [:stdout,:stderr,:return_code,:log_file]
  error_indicators: {
    stdout: %W{ word1 word2 }
    stderr: %W{ word1 word2 }
    log_file: %W{ word1 word2 }
    return_code: [1,2,3,4]
  }
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
