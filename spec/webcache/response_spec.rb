require 'spec_helper'

describe WebCache::Response do
  describe '#new' do
    context 'with hash' do
      let :response do
        described_class.new({
          error:    'problemz',
          base_uri: 'sky.net',
          content:  'robots',
          code:     200,
        })
      end

      it 'sets error' do
        expect(response.error).to eq 'problemz'
      end

      it 'sets base_uri' do
        expect(response.base_uri).to eq 'sky.net'
      end

      it 'sets content' do
        expect(response.content).to eq 'robots'
      end

      it 'sets code' do
        expect(response.code).to eq 200
      end
    end

    context 'with HTTP response' do
      let(:http_response) { HTTP.follow.get 'http://example.com' }
      let(:response) { described_class.new http_response }

      it 'sets error' do
        expect(response.error).to be_nil
      end

      it 'sets base_uri' do
        expect(response.base_uri.to_s).to eq 'http://example.com/'
      end

      it 'sets content' do
        expect(response.content).to match 'Example Domain'
      end

      it 'sets code' do
        expect(response.code).to eq 200
      end
    end
  end

  describe '#to_s' do
    let(:response) { described_class.new content: 'robots' }

    it 'returns the content' do
      expect(response.to_s).to eq 'robots'
    end
  end

  describe '#success?' do
    context 'when there was an error' do
      let(:response) { described_class.new error: 'robots' }

      it 'returns false' do
        expect(response.success?).to be false
      end
    end

    context 'when there was no error' do
      let(:response) { described_class.new content: 'robots' }

      it 'returns true' do
        expect(response.success?).to be true
      end
    end
  end
end
