module CommandExec
  class Executable

    # @!attribute [r] path
    #   path to executable
    attr_reader :path, :path_resolver, :path_cleaner
    private     :path, :path_resolver, :path_cleaner

    # Create executable
    #
    # @param [ Path ] path
    #   path to executable
    def initialize( local_path, options = {} )
      @path          = local_path
      @path_resolver = PathResolver.new( search_paths: determine_search_paths( local_path , options ) )
      @path_cleaner  = PathCleaner.new

      after_init
    end


    # Absolute path to executable
    #
    # @return [String] absolute path to executable, '' if lookup failed
    def absolute_path
      path_resolver.absolute_path( path_cleaner.cleanup( path.to_s ) )
    end

    private

    def after_init; end

    def determine_search_paths( local_path, hash )
      return SearchPath.new( local_path ).to_a if hash[ :search_paths ].blank?
      Array( hash.fetch( :search_paths , SearchPath.new( local_path ).to_a ) )
    end

  end
end
