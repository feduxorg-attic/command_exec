require 'spec_helper'

describe PathResolver do
  context '#absolute_path' do
    it "resolves name if is full qualified" do
      cmd      = 'file'
      file     = create_file( cmd , '' , 0755 )
      resolver = PathResolver.new
      path     = resolver.absolute_path( file )
      expect( path  ).to eq( file )
    end

    it "resolves name if is not full qualified" do
      cmd      = 'file'
      file     = create_file( cmd , '' , 0755 )
      resolver = PathResolver.new( search_paths: [ working_directory ] )
      path     = resolver.absolute_path( cmd )
      expect( path  ).to eq( file )
    end

    it "support the use of extensions (mind the '.')" do
      cmd      = 'file'
      extension = '.ext'
      file     = create_file( "#{cmd}#{extension}" , '' , 0755 )
      resolver = PathResolver.new( search_paths: working_directory , extensions: [ extension ] )
      path     = resolver.absolute_path( cmd )
      expect( path  ).to eq( file )
    end

    it "uses the PATH-environment variable by default" do
      cmd      = 'file'
      file     = create_file( cmd , '', 0755 )

      resolver = isolated_environment 'PATH' => working_directory do
        PathResolver.new
      end

      path = resolver.absolute_path( cmd )
      expect( path ).to eq( file )
    end

    it "uses the PATHEXT-environment variable for extensions by default" do
      cmd       = 'file'
      extension = '.ext'
      file      = create_file( "#{cmd}#{extension}" , '', 0755 )

      resolver = isolated_environment 'PATHEXT' => extension  do
        PathResolver.new( search_paths: working_directory )
      end

      path = resolver.absolute_path( cmd )
      expect( path ).to eq( file )
    end

    it "returns nil by default if no suitable executable file can be found in path" do
      cmd      = 'asdf'
      resolver = PathResolver.new( search_paths: [ working_directory ] )
      path     = resolver.absolute_path( cmd )
      expect( path  ).to eq( nil )
    end

    it "raises an exception on request if no suitable file can be found in path" do
      cmd      = 'asdf'
      resolver = PathResolver.new( search_paths: [ working_directory ], raise_error: true )
      expect{ resolver.absolute_path( cmd ) }.to raise_error Exceptions::CommandNotFound
    end

    it "raises an exception on request if no suitable file can be found in path for fully qualified path" do
      cmd      = '/tmp/asdf'
      resolver = PathResolver.new( search_paths: [ working_directory ], raise_error: true )
      expect{ resolver.absolute_path( cmd ) }.to raise_error Exceptions::CommandNotFound
    end

    it "support string search path" do
      cmd      = 'file'
      file     = create_file( cmd, '', 0755 )
      resolver = PathResolver.new( search_paths: working_directory )
      path     = resolver.absolute_path( cmd )
      expect( path  ).to eq( file )
    end

    it "support string extension" do
      cmd       = 'file'
      extension = '.ext'
      file      = create_file( "#{cmd}#{extension}", '', 0755 )
      resolver  = PathResolver.new( search_paths: [ working_directory ], extensions: extension )
      path      = resolver.absolute_path( cmd )
      expect( path  ).to eq( file )
    end
  end
end
