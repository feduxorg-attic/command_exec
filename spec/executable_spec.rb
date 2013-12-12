require 'spec_helper'

describe Executable do

  context '#exists?' do
    it "succeeds if file exists" do
      file = create_file( 'file', '', 0755 )
      exec = Executable.new( file )
      expect( exec ).to be_exists
    end

    it "fails if file does not exist" do
      exec = Executable.new( 'asdf' )
      expect( exec ).not_to be_file
    end

    it "works with symbols as well" do
      file = create_file( 'file', '' , 0755 )
      exec = Executable.new( :file, search_paths: working_directory )
      expect( exec ).to be_exists
    end

  end

  context '#file?' do
    it "succeeds if file exists and really is a file" do
      exec = Executable.new( '/usr/bin/which' )
      expect( exec ).to be_file
    end

    it "fails if file exists but is not a file" do
      dir = create_directory( 'directory' )
      exec = Executable.new( dir )
      expect( exec ).not_to be_file
    end
 
    it "supports symbols as well" do
      dir = create_file( 'file', '', 0755 )
      exec = Executable.new( :file, search_paths: working_directory )
      expect( exec ).to be_file
    end end

  context '#executable?' do
    it "succeeds if file is executable" do
      exec = Executable.new( '/usr/bin/which' )
      expect( exec ).to be_executable
    end

    it "fails if file is not executable" do
      file = create_file( 'blub', '', 0644 )
      exec = Executable.new( file )
      expect( exec ).not_to be_executable
    end

    it "supports symbols as well" do
      file = create_file( 'blub', '', 0755 )
      exec = Executable.new( :blub, search_paths: working_directory )
      expect( exec ).to be_executable
    end
  end

  context '#absolute_path' do
    it "returns absolute path to command" do
      exec = Executable.new( :which )
      isolated_environment 'PATH' => '/usr/bin' do
        expect( exec.absolute_path ).to eq( '/usr/bin/which' )
      end
    end
  end

  context '#validate' do
    it "does nothing if all tests pass" do
      exec = Executable.new( '/usr/bin/which' )
      expect { exec.validate }.not_to raise_error
    end

    it "raises an exception if exist-test fails" do
      exec = Executable.new( 'asdf')
      expect { exec.validate }.to raise_error CommandExec::Exceptions::CommandNotFound
    end

    it "raises an exception if file-test fails" do
      dir = create_directory( 'directory' )
      exec = Executable.new( dir )
      expect { exec.validate }.to raise_error CommandExec::Exceptions::CommandIsNotAFile
    end

    it "raises an exception if executable-test fails" do
      file = create_file( 'file', '', 0644 )
      exec = Executable.new( file )
      expect { exec.validate }.to raise_error CommandExec::Exceptions::CommandNotExecutable
    end
  end
end
