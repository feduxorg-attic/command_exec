# encoding: utf-8

# Main
module CommandExec
  # Classed concerning pdflatex exceptions
  module Exceptions
    # Class used to indicate that a command 
    # could not be found in file system
    class CommandNotFound < RuntimeError; end
    
    # Class used to indicate that a command 
    # is not flagged as executable
    #
    # @example
    # chmod +x <executable>
    class CommandNotExecutable < RuntimeError; end
    
    # Class used to indicate that a command 
    # is not a file
    class CommandIsNotAFile < RuntimeError; end
    
    # Class used to indicate that a command run
    # ended with a failure 
    class ExecuteCommandFailed < RuntimeError; end
    
    # Class used to indicate that a logfile
    # could not be found in file system
    class LogfileNotFound < RuntimeError; end
  end
end
