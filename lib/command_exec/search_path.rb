require 'pathname'

module CommandExec
  class SearchPath
    private

    attr_reader :paths

    public

    def initialize( cmd = nil )
      if cmd.nil?
        @paths = default_path
      elsif cmd.kind_of? Symbol
        @paths = default_path
      elsif Pathname.new( cmd ).absolute?
        @paths = default_path
      else
        @paths = current_directory
      end
    end

    private

    def default_path
      ENV['PATH']
    end

    def current_directory
      Dir.getwd
    end

    public

    def to_a(separator=':')
      paths.split( separator )
    end

    def to_s(connector=',')
      to_a.join( connector )
    end
  end
end
