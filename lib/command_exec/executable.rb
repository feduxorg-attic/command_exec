module CommandExec
  class Executable

    # @!attribute [r] path
    #   path to executable
    attr_reader :path
    private     :path

    # Create executable
    #
    # @param [ Path ] path
    #   path to executable
    def initialize( p, options = {} )
      @path          = p
      @path_resolver = PathResolver.new( search_paths( p , options ) )
      @path_cleaner  = PathCleaner.new

      after_init
    end

    def after_init; end

    # Absolute path to executable
    #
    # @return [String] absolute path to executable, '' if lookup failed
    def absolute_path
      @path_resolver.absolute_path( @path_cleaner.cleanup( path ) )
    end

    private

    def exists?
      File.exists? absolute_path
    end

    def executable?
      File.executable? absolute_path
    end

    def file?
      File.file? absolute_path
    end

    public

    # Validate executable
    #
    # @raise [CommandExec::Exceptions::CommandNotFound] if command does not exist
    # @raise [CommandExec::Exceptions::CommandNotExecutable] if command is not executable
    # @raise [CommandExec::Exceptions::CommandIsNotAFile] if command is not a file
    def validate
      raise Exceptions::CommandNotFound , "Command '#{path}' not found." unless exists?
      raise Exceptions::CommandIsNotAFile, "Command '#{path}' not a file." unless file?
      raise Exceptions::CommandIsNotExecutable , "Command '#{path}' not executable." unless executable?
    end

    private

    def search_paths( p, options )
      Array( options.fetch( :search_paths , SearchPath.new( p ).to_a ) )
    end

  end
end
