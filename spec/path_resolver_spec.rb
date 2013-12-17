require 'spec_helper'

describe PathResolver do
  context '#absolute_path' do
    it "resolves name if is full qualified" do
      cmd      = 'file'
      file     = create_file(cmd , '' , 0755)
      resolver = PathResolver.new
      path     = resolver.absolute_path(file)
      expect(path).to eq(file)
    end

    it "resolves name if is not full qualified" do
      cmd      = 'file'
      file     = create_file(cmd , '' , 0755)
      resolver = PathResolver.new(search_paths: [ working_directory ])
      path     = resolver.absolute_path(cmd)
      expect(path).to eq(file)
    end

    it "support the use of extensions (mind the '.')" do
      cmd      = 'file'
      extension = '.ext'
      file     = create_file("#{cmd}#{extension}" , '' , 0755)
      resolver = PathResolver.new(search_paths: working_directory , extensions: [ extension ])
      path     = resolver.absolute_path(cmd)
      expect(path).to eq(file)
    end

    it "uses the PATH-environment variable by default" do
      cmd      = 'file'
      file     = create_file(cmd , '', 0755)

      resolver = isolated_environment 'PATH' => working_directory do
        PathResolver.new
      end

      path = resolver.absolute_path(cmd)
      expect(path).to eq(file)
    end

    it "uses the PATHEXT-environment variable for extensions by default" do
      cmd       = 'file'
      extension = '.ext'
      file      = create_file("#{cmd}#{extension}" , '', 0755)

      resolver = isolated_environment 'PATHEXT' => extension  do
        PathResolver.new(search_paths: working_directory)
      end

      path = resolver.absolute_path(cmd)
      expect(path).to eq(file)
    end

    it "raises an exception if no suitable file can be found in path" do
      cmd      = 'asdf'
      resolver = PathResolver.new(search_paths: [ working_directory ])
      expect{ resolver.absolute_path(cmd)}.to raise_error Exceptions::CommandNotFound
    end

    it "raises an exception if file is found in PATH-environment var but is not executable" do
      cmd      = 'asdf'
      create_file(cmd, '', 0644)
      resolver = PathResolver.new(search_paths: [ working_directory ])
      expect{ resolver.absolute_path(cmd)}.to raise_error Exceptions::CommandIsNotExecutable
    end

    it "raises an exception if file is found in PATH-environment var but is not a file" do
      cmd      = 'asdf'
      create_directory(cmd)
      resolver = PathResolver.new(search_paths: [ working_directory ])
      expect{ resolver.absolute_path(cmd)}.to raise_error Exceptions::CommandIsNotAFile
    end

    it "raises an exception if fully qualified path does not exist" do
      cmd      = '/tmp/asdf'
      resolver = PathResolver.new(search_paths: [ working_directory ])
      expect{ resolver.absolute_path(cmd)}.to raise_error Exceptions::CommandNotFound
    end

    it "raises an exception if fully qualified path is not executable" do
      cmd = create_file('file' , '', 0644)
      resolver = PathResolver.new(search_paths: [ working_directory ])
      expect{ resolver.absolute_path(cmd)}.to raise_error Exceptions::CommandIsNotExecutable
    end

    it "raises an exception if fully qualified path is not a file" do
      cmd = create_directory('dir')
      resolver = PathResolver.new(search_paths: [ working_directory ])
      expect{ resolver.absolute_path(cmd)}.to raise_error Exceptions::CommandIsNotAFile
    end

    it "support string search path" do
      cmd      = 'file'
      file     = create_file(cmd, '', 0755)
      resolver = PathResolver.new(search_paths: working_directory)
      path     = resolver.absolute_path(cmd)
      expect(path).to eq(file)
    end

    it "support string extension" do
      cmd       = 'file'
      extension = '.ext'
      file      = create_file("#{cmd}#{extension}", '', 0755)
      resolver  = PathResolver.new(search_paths: [ working_directory ], extensions: extension)
      path      = resolver.absolute_path(cmd)
      expect(path).to eq(file)
    end
  end
end
