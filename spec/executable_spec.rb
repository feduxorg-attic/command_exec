require 'spec_helper'

describe Executable do

  context '#absolute_path' do
    it "returns path to command given as symbol" do
      cmd  = :file
      file = create_file( cmd.to_s, '', 0755 )

      exec = isolated_environment 'PATH' => working_directory do
        Executable.new( cmd )
      end

      expect( exec.absolute_path ).to eq( file )
    end

    it "returns path to command given as string" do
      cmd  = 'file'
      file = create_file( cmd, '', 0755 )

      exec = switch_to_working_directory do
        Executable.new( cmd )
      end

      expect( exec.absolute_path ).to eq( file )
    end

    it "returns path to command given as absolute path as string" do
      cmd = create_file( 'file', '', 0755 )

      exec = switch_to_working_directory do
        Executable.new( cmd )
      end

      expect( exec.absolute_path ).to eq( cmd )
    end
  end
end
