require 'spec_helper'

describe PathCleaner do
  context '#cleanup' do

    it 'happens nothing if none was chosen' do
      path = './which'

      cleaner = PathCleaner.new
      expect( cleaner.cleanup( path ) ).to eq( './which' )
    end

    it 'deletes ./ from path if told to do so' do
      path = './which'

      cleaner = PathCleaner.new( simple: true )
      expect( cleaner.cleanup( path ) ).to eq( 'which' )
    end

    it 'deletes ../ from path if told to do so' do
      path = '../which'

      cleaner = PathCleaner.new( secure_path: true )
      expect( cleaner.cleanup( path ) ).to eq( 'which' )
    end

    it 'uses pathname to cleanup path' do
      path = '/usr/../which'

      cleaner = PathCleaner.new( pathname: true )
      expect( cleaner.cleanup( path ) ).to eq( '/which' )
    end

    it 'cleans up everything and deletes unsecure ../ before running other filters' do
      path = '/usr/../which/./lala/./asdf'

      cleaner = PathCleaner.new( pathname: true, secure_path: true )
      expect( cleaner.cleanup( path ) ).to eq( '/usr/which/lala/asdf' )
    end
  end
end
