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
      raise_error  = options[:raise_error]

      if raise_error
        @resolver = ResolverWithExceptions.new( Array( search_paths ), Array( extensions ) )
      else
        @resolver = ResolverWithNil.new( Array( search_paths ), Array( extensions ) )
      end
    end

    # Find the absolute path to cmd
    #
    # @return [String]
    #   The absolute path to the command
    def absolute_path( cmd )
      resolver.which( cmd )
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
        raise_error:  false,
        search_paths: default_search_paths,
        extensions:   default_extensions,
      }
    end

    class BaseResolver
      attr_reader :search_paths, :extensions
      private     :search_paths, :extensions

      def initialize( search_paths, extensions )
        @search_paths = search_paths
        @extensions   = extensions
      end
    end

    # Class to handle path resolve and raise exception on command no found
    class ResolverWithExceptions < BaseResolver
      def which( cmd )
        raise Exception::CommandNotFound if cmd.blank?
        return cmd if Pathname.new( cmd ).absolute? and File.executable? cmd

        search_paths.each do |path|
          extensions.each do |ext|
            file = File.join( path, "#{cmd}#{ext}" )
            return file if File.executable? file
          end
        end

        raise Exception::CommandNotFound
      end
    end

    # Class to handle path resolve and return nil on command no found
    class ResolverWithNil < BaseResolver
      def which( cmd )
        return nil if cmd.blank?
        return cmd if Pathname.new( cmd ).absolute? and File.executable? cmd

        search_paths.each do |path|
          extensions.each do |ext|
            file = File.join( path, "#{cmd}#{ext}" )
            return file if File.executable? file
          end
        end

        nil
      end
    end
  end
end
