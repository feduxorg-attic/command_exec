#encoding: utf-8

#Main
module CommandExec
  # Shared methods for fields
  module FieldHelper

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
            status:      'STATUS',
            return_code: 'RETURN CODE',
            log_file:    'LOG FILE',
            stderr:      'STDERR',
            stdout:      'STDOUT',
            pid:         'PID',
            reason_for_failure: 'REASON FOR FAILURE',
            executable: 'EXECUTABLE',
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
      ] 
    end
  end
end
