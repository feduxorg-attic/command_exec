# encoding: utf-8
require 'spec_helper'

describe Executable do

  context '# absolute_path' do
    it 'triggers path resolver' do
      cmd  = 'file'
      file = create_file(cmd, '', 0755)
      exec = Executable.new(cmd, search_paths: working_directory)
      expect(exec.absolute_path).to eq(file)
    end
  end
end

describe SecuredExecutable do
  it 'triggers path cleaner as well: deletes ./ and ../' do
    cmd  = '.././file'
    file = create_file(File.basename(cmd), '', 0755)
    exec = SecuredExecutable.new(cmd, search_paths: working_directory)
    expect(exec.absolute_path).to eq(file)
  end

  it 'triggers path cleaner as well: deletes ..' do
    cmd  = 'usr/../file'
    file = create_file('usr/file', '', 0755)
    exec = SecuredExecutable.new(cmd, search_paths: working_directory)
    expect(exec.absolute_path).to eq(file)
  end
end

describe SimpleExecutable do
  it 'triggers path cleaner as well: deletes ./' do
    cmd  = './file'
    file = create_file(File.basename(cmd), '', 0755)
    exec = SimpleExecutable.new(cmd, search_paths: working_directory)
    expect(exec.absolute_path).to eq(file)
  end

  it 'triggers path cleaner as well: does not delete ..' do
    cmd  = 'usr/../file'
    file = create_file('file', '', 0755)
    exec = SimpleExecutable.new(cmd, search_paths: working_directory)
    expect(exec.absolute_path).to eq(file)
  end
end
