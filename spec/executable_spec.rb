require 'spec_helper'

describe Executable, :focus do

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
  end

  context '#executable?' do
    it "succeeds if file is executable" do
      exec = Executable.new( '/usr/bin/which' )
      expect( exec ).to be_executable
    end

    it "fails if file is not executable" do
      file = create_file( 'blub ' )
      exec = Executable.new( file )
      expect( exec ).not_to be_executable
    end
  end

  context '#valid?' do
    it "succeeds if is a file and executable" do
      exec = Executable.new( '/usr/bin/which' )
      expect( exec ).to be_valid
    end
  end
end
