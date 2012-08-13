* Check if attr_accessor or attr_reader is better in command.rb

* alias run_successful? to success?
* refactor lib interface
```ruby
#options
  error_detection_on: [:stdout,:stderr,:status,:log_file]
  error_indicators: {
    stdout: %W{ word1 word2 }
    stderr: %W{ word1 word2 }
    log_file: %W{ word1 word2 }
    status: false
  }
  on_error: [:do_nothing, :return_status, :raise_exception ]

#raise_exception with serialized status object
require 'json'
raise ExecuteCommandFailed , JSON.dump status 
```
* 
