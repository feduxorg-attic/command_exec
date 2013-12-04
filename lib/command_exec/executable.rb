module CommandExec
  class Executable

    private

    attr_reader :path

    public

    # Create executable
    #
    # @param [ Path ] path
    #   path to executable
    def initialize( path )
      @path = path
    end

    # Does the file exists
    # 
    # @return [true,false] result of check
    def exists?
      File.exists? path
    end

    # Is the path executable
    # 
    # @return [true,false] result of check
    def executable?
      File.executable? path
    end

    # Is the provided string a file
    # 
    # @return [true,false] result of check
    def file?
      File.file? path
    end

    # Validate executable
    #
    # @raise [CommandExec::Exceptions::CommandNotFound] if command does not exist
    # @raise [CommandExec::Exceptions::CommandNotExecutable] if command is not executable
    # @raise [CommandExec::Exceptions::CommandIsNotAFile] if command is not a file
    def validate
      unless exists?
        CommandExec.logger.fatal("Executable \"#{path}\" cannot be found.")
        raise Exceptions::CommandNotFound , "Command '#{path}' not found."
      end

      unless file?
        CommandExec.logger.fatal("Path '#{path}' is not a file.")
        raise Exceptions::CommandIsNotAFile, "Command '#{path}' not a file."
      end

      unless executable?
        CommandExec.logger.fatal("Path '#{path}' is not executable.")
        raise Exceptions::CommandNotExecutable , "Command '#{path}' not executable."
      end
    end
  end
end
