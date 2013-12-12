require 'spec_helper'

describe PathResolver do
  context '#absolute_path' do
    it "resolves name if is full qualified" do
      cmd      = '/usr/bin/which'
      resolver = PathResolver.new( search_paths: [ ] )
      path     = resolver.absolute_path( cmd )
      expect( path  ).to eq( '/usr/bin/which' )
    end

    it "resolves name if is not full qualified" do
      cmd      = 'which'
      resolver = PathResolver.new( search_paths: [ '/usr/bin' ] )
      path     = resolver.absolute_path( cmd )
      expect( path  ).to eq( '/usr/bin/which' )
    end

    it "support the use of extension (mind the '.')", :focus do
      cmd      = 'mkfs'
      resolver = PathResolver.new( search_paths: [ '/usr/bin' ], extensions: [ '.ext4' ] )
      path     = resolver.absolute_path( cmd )
      expect( path  ).to eq( '/usr/bin/mkfs.ext4' )
    end

    it "returns nil by default if no suitable executable file can be found in path" do
      cmd      = 'asdf'
      resolver = PathResolver.new( search_paths: [ '/usr/bin' ] )
      path     = resolver.absolute_path( cmd )
      expect( path  ).to eq( nil )
    end

    it "raises an exception on request if no suitable file can be found in path" do
      cmd      = 'asdf'
      resolver = PathResolver.new( search_paths: [ '/usr/bin' ], raise_error: true )
      expect{ resolver.absolute_path( cmd ) }.to raise_error Exceptions::CommandNotFound
    end

    it "raises an exception on request if no suitable file can be found in path for fully qualified path" do
      cmd      = '/tmp/asdf'
      resolver = PathResolver.new( search_paths: [ '/usr/bin' ], raise_error: true )
      expect{ resolver.absolute_path( cmd ) }.to raise_error Exceptions::CommandNotFound
    end

    it "support string search path" do
      cmd      = 'which'
      resolver = PathResolver.new( search_paths: '/usr/bin' )
      path     = resolver.absolute_path( cmd )
      expect( path  ).to eq( '/usr/bin/which' )
    end

    it "support string extension", :focus do
      cmd      = 'mkfs'
      resolver = PathResolver.new( search_paths: '/usr/bin', extensions: '.ext4' )
      path     = resolver.absolute_path( cmd )
      expect( path  ).to eq( '/usr/bin/mkfs.ext4' )
    end

  end

end
