require 'spec_helper'

describe SearchPath do
  context '#new' do

    it 'uses ENV[\'PATH\'] if nil' do
      isolated_environment 'PATH' => '/bin' do
        expect( SearchPath.new.to_a ).to eq( [ '/bin' ] )
      end
    end

    it 'uses PWD by default' do
      expect( SearchPath.new('asdf').to_a ).to eq( [ Dir.getwd ] )
    end

    it 'uses ENV[\'PATH\'] if symbol is given' do
      isolated_environment 'PATH' => '/bin' do
        expect( SearchPath.new( :cmd ).to_a ).to eq( [ '/bin' ] )
      end
    end
  end

  context '#to_a' do
    it 'splits up at ":" by default' do
      isolated_environment 'PATH' => '/bin:/usr/bin' do
        expect( SearchPath.new.to_a ).to eq( [ '/bin', '/usr/bin' ] )
      end
    end

    it 'splits up at given string' do
      isolated_environment 'PATH' => '/bin,/usr/bin' do
        expect( SearchPath.new.to_a( ',' ) ).to eq( [ '/bin', '/usr/bin' ] )
      end
    end
  end

  context '#to_s' do
    it 'returns a comma separated list by default' do
      isolated_environment 'PATH' => '/bin:/usr/bin' do
        expect( SearchPath.new.to_s ).to eq( '/bin,/usr/bin' )
      end
    end

    it 'connects path by given string' do
      isolated_environment 'PATH' => '/bin:/usr/bin' do
        expect( SearchPath.new.to_s(':') ).to eq( '/bin:/usr/bin' )
      end
    end
  end
end
