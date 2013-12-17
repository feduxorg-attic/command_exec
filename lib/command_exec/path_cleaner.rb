# encoding: utf-8
module CommandExec
  class PathCleaner
    def initialize(options = {})
      options = default_options.merge options

      @cleaners = []
      @cleaners << NullCleaner.new
      @cleaners << SecurePathCleaner.new if options[:secure_path]
      @cleaners << PathnameCleaner.new   if options[:pathname]
      @cleaners << SimplePathCleaner.new if options[:simple]
    end

    def cleanup( path )
      @cleaners.reduce( path ) do |result, c|
        c.process( result )
      end
    end

    private

    def default_options
      {
        secure_path: false,
        path_name:   false,
        simple: false
      }
    end

    class NullCleaner
      def process( path )
        path
      end
    end

    class PathnameCleaner
      def process( path )
        require 'pathname'
        Pathname.new( path.to_s ).cleanpath.to_s
      end
    end

    class SimplePathCleaner
      def process( path )
        path.to_s.gsub( %r{(?<!\.)\./} , '' )
      end
    end

    class SecurePathCleaner
      def process( path )
        path.to_s.gsub( %r{\.\./} , '' )
      end
    end
  end
end
