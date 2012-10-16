#encoding: utf-8

#Main
module CommandExec
  # Shared methods for fields
  module FieldHelper

    # Initialize helper
    #
    # will be used from array and hash via super call although there's no
    # inheritance.
    # See for more information http://stackoverflow.com/questions/1645398/ruby-include-question
    def initialize
      @end_time = []
      @executable = []
      @log_file = []
      @pid = []
      @reason_for_failure = []
      @return_code = []
      @start_time = []
      @status = []
      @stderr = []
      @stdout = []
    end

    # Return the available header names
    #
    # @return [Hash] the names of the headers
    #
    #   * :status [String]: 'STATUS'
    #   * :return_code [String]: 'RETURN CODE'
    #   * :log_file [String]: 'LOG FILE'
    #   * :stderr [String]: 'STDERR'
    #   * :stdout [String]: 'STDOUT'
    #   * :pid [String]: 'PID'
    #   * :reason\_for\_failure [String]: 'REASON FOR FAILURE'
    #   * :executable [String]: 'EXECUTABLE'
    #
    def header_names
      {
        headers: {
          names: {
            status:       'STATUS',
            return_code:  'RETURN CODE',
            log_file:     'LOG FILE',
            stderr:       'STDERR',
            stdout:       'STDOUT',
            pid:          'PID',
            reason_for_failure: 'REASON FOR FAILURE',
            executable:   'EXECUTABLE',
            start_time:   'START TIME',
            end_time:     'END TIME',
          },
        }
      }
    end

    # Return the available fields for output
    #
    # @return [Hash] the available fields with the corresponding instance
    #   variable
    def available_fields
      {
        :status => @status,
        :return_code => @return_code,
        :stderr => @stderr,
        :stdout => @stdout,
        :log_file => @log_file,
        :pid => @pid,
        :reason_for_failure => @reason_for_failure,
        :executable => @executable,
        :start_time => @start_time,
        :end_time => @end_time,
      }
    end

    # Return the default fields for output
    #
    # @return [Array] the names of the fields which should be outputted by
    #   default 
    def default_fields
      [:status,
       :return_code,
       :stderr,
       :stdout,
       :log_file,
       :pid,
       :reason_for_failure,
       :executable,
       :start_time,
       :end_time,
      ] 
    end

    # Set the content of the log file
    #
    # @param content [Array,String]
    #   The content of log file
    #
    # @return [Array] the content of the log file
    def log_file(*content)
      @log_file += content.flatten
    end

    # Set the return code of the command
    #
    # @param value [Number,String]
    #   Set the return code(s) of the command. 
    #
    # @return [Array] the return code
    def return_code(value)
      @return_code[0] = value.to_s

      @return_code
    end

    # Set the content of stdout
    #
    # @param content [Array,String]
    #   The content of stdout
    #
    # @return [Array]
    def stdout(*content)
      @stdout += content.flatten
    end

    # Set the content of stderr
    #
    # @param content [Array,String]
    #   The content of stderr
    #
    # @return [Array]
    def stderr(*content)
      @stderr += content.flatten
    end

    # Set the pid of the command
    #
    # @param value [Number,String]
    #   Set the pid of the command. 
    #
    # @return [Array]
    def pid(value)
      @pid[0] = value.to_s

      @pid
    end

    # Set the reason for failure
    #
    # @param content [Array, String] 
    #   Set the reason for failure.
    #
    # @return [Array]
    def reason_for_failure(*content)
      @reason_for_failure += content.flatten
    end
      
    # Set the path to the executable of the command
    #
    # @param [String] value
    #  the path to the executable
    #
    # @return [Array]
    #   the executable
    def executable(value)
      @executable[0] = value
    end
    
    # Set the status of the command
    #
    # @param [String,Symbol] value
    #   Set the status of the command based on input.
    #
    # @param [Hash] options
    #   Options for status
    #
    # @option options [True,False] :color
    #   Should the output be colored
    #
    # @return [Array] 
    #   the formatted status. It returns `OK` (in bold and green) if status is
    #   `:success` and `FAILED` (in bold and red) if status is `:failed`.
    #
    def prepare_status(value,options={})

      case value.to_s
      when 'success'
        @status[0] = message_success(color: options[:color])
      when 'failed'
        @status[0] = message_failure(color: options[:color])
      else
        @status[0] = message_failure(color: options[:color])
      end

      @status
    end

    # Returns the success message
    #
    # @param [Hash] options
    #   options
    #
    # @option options [True,False] :color
    #   should the message return in color
    #
    # @return [String] the message
    def message_success(options={})
      message = 'OK'

      if options[:color] 
        return message.green.bold
      else
        return message
      end
    end

    # Returns the failure message
    #
    # @param [Hash] options
    #   options
    #
    # @option options [True,False] :color
    #   should the message return in color
    #
    # @return [String] the message
    def message_failure(options)
      message = 'FAILED'

      if options[:color] 
        return message.red.bold
      else
        return message
      end
    end
  end
end
