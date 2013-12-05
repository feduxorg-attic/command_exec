module CommandExec
  class Executable

    private

    include FeduxOrg::Stdlib::Command::Which

    # @!attribute [r] path
    #   path to executable
    attr_reader :path, :search_paths

    public

    # Create executable
    #
    # @param [ Path ] path
    #   path to executable
    def initialize( path, search_paths=CommandExec.search_paths )
      @path         = path
      @search_paths = search_paths
    end

    # Absolute path to executable
    #
    # @return [String] absolute path to executable
    def absolute_path
      return which( path.to_s, Dir.getwd ) if path.kind_of? Symbol

      which( path, search_paths )
    end

    # Does the path exists
    # 
    # @return [true,false] result of check
    def exists?
      File.exists? path.to_s
    end

    # Is the path executable
    # 
    # @return [true,false] result of check
    def executable?
      File.executable? path.to_s
    end

    # Is the provided string a path
    # 
    # @return [true,false] result of check
    def file?
      File.file? path.to_s
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
