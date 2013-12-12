module CommandExec
  class PathResolver

    attr_reader :resolver
    private     :resolver

    # New path resolver
    #
    # @param [String] cmd
    #   The command which needs to be found in path
    def initialize( options = {} )
      options      = default_options.merge options

      search_paths = options[:search_paths]
      extensions   = options[:extensions]

      @resolver = Resolver.new( Array( search_paths ), Array( extensions ) )
    end

    # Find the absolute path to cmd
    #
    # @return [String]
    #   The absolute path to the command
    def absolute_path( cmd )
      resolver.absolute_path( cmd )
    end

    private

    def default_search_paths
      paths = ENV['PATH'].to_s.split(File::PATH_SEPARATOR)

      return %w{ /bin /usr/bin } if paths.blank?
      paths
    end

    def default_extensions
      exts = ENV['PATHEXT'].to_s.split( /;/ )

      return [''] if exts.blank?
      exts
    end

    def default_options
      {
        search_paths: default_search_paths,
        extensions:   default_extensions,
      }
    end

    class BaseResolver
    end

    # Class to handle path resolve and raise exception on command no found
    class Resolver
      attr_reader :search_paths, :extensions
      private     :search_paths, :extensions

      # Create new resolver
      #
      # @param [Array] search_paths
      #   List of search paths 
      #
      # @param [Array] extension
      #   List of file extension
      def initialize( search_paths, extensions )
        @search_paths = search_paths
        @extensions   = extensions
      end

      # Try to determine absolute path for command 
      #
      # @param [String] cmd
      #   Command or absolute/relative path to command
      #  
      # @return [String]
      #  Path to command 
      #
      # @raise [Exception::CommandNotFound]
      #   raised if `cmd` is blank or does not exist
      def absolute_path( cmd )
        raise Exception::CommandNotFound if cmd.blank?

        if Pathname.new( cmd ).absolute? 
          raise Exception::CommandNotFound, cmd        unless File.exists? cmd
          raise Exception::CommandIsNotAFile, cmd      unless File.file? cmd
          raise Exception::CommandIsNotExecutable, cmd  unless File.executable? cmd

          return cmd
        end

        search_paths.each do |path|
          extensions.each do |ext|
            file = File.join( path, "#{cmd}#{ext}" )
            raise Exception::CommandIsNotAFile, file      if File.exists? file and not File.file? file
            raise Exception::CommandIsNotExecutable, file if File.exists? file and not File.executable? file
            return file if File.executable? file
          end
        end

        raise Exception::CommandNotFound
      end
    end

  end
end
