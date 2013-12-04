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

    # Is executable valid
    #
    # @return [true,false] result of check
    def valid?
      file? and executable?
    end
  end
end
