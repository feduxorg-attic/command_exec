require 'spec_helper'

describe Executable do

  context '#absolute_path' do
    it "resolves name if is full qualified" do
      exec = Executable.new( '/usr/bin/which' )
      expect( exec.absolute_path ).to eq( '/usr/bin/which' )
    end

    it "resolves path based on PATH if is symbol" do
      file = create_file( 'which', '', 0755 )
      exec = Executable.new( :which, working_directory )

      switch_to_working_directory do
        expect( exec.absolute_path ).to eq( file )
      end
    end

    it "resolves executables only" do
      file1 = create_file( 'file1', '', 0644 )
      file2 = create_file( 'file2', '', 0755 )

      exec1 = Executable.new( 'file1' )
      exec2 = Executable.new( 'file2' )

      switch_to_working_directory do
        expect( exec1 ).not_to be_exists
        expect( exec2 ).to be_exists
      end

    end

    it "resolves path based on PWD if is a string and a relative path (it does not start with \"/\")" do
      file = create_file( 'file', '', 0755 )

      exec = Executable.new( 'file' )

      switch_to_working_directory do
        expect( exec ).to be_exists
      end

    end
  end

  context '#exists?' do
    it "succeeds if file exists" do
      file = create_file( 'file' )
      exec = Executable.new( file )
      expect( exec ).to be_exists
    end

    it "fails if file does not exist" do
      exec = Executable.new( 'asdf' )
      expect( exec ).not_to be_file
    end

    it "works with symbols as well" do
      file = create_file( 'file', '' , 0755 )
      exec = Executable.new( :file , working_directory )
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
      exec = Executable.new( :file, working_directory )
      expect( exec ).to be_file
    end end

  context '#executable?' do
    it "succeeds if file is executable" do
      exec = Executable.new( '/usr/bin/which' )
      expect( exec ).to be_executable
    end

    it "fails if file is not executable" do
      file = create_file( 'blub' )
      exec = Executable.new( file )
      expect( exec ).not_to be_executable
    end

    it "supports symbols as well" do
      file = create_file( 'blub', '', 0755 )
      exec = Executable.new( :blub, working_directory )
      expect( exec ).to be_executable
    end
  end

  context '#validate' do
    it "does nothing if all tests pass" do
      exec = Executable.new( '/usr/bin/which' )
      expect { exec.validate }.not_to raise_error
    end

    it "raises an exception if exist-test fails" do
      exec = Executable.new( 'asdf')
      silence( :stderr ) do
        expect { exec.validate }.to raise_error CommandExec::Exceptions::CommandNotFound
      end
    end

    it "raises an exception if file-test fails" do
      dir = create_directory( 'directory' )
      exec = Executable.new( dir )
      silence( :stderr ) do
        expect { exec.validate }.to raise_error CommandExec::Exceptions::CommandIsNotAFile
      end
    end

    it "raises an exception if executable-test fails" do
      file = create_file( 'file' )
      exec = Executable.new( file )
      silence( :stderr ) do
        expect { exec.validate }.to raise_error CommandExec::Exceptions::CommandNotExecutable
      end
    end
  end
end
