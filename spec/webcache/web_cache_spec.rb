require 'spec_helper'
require 'fileutils'

describe WebCache do
  let(:cache) { WebCache.new }
  let(:url) { 'http://example.com' }

  before do 
    FileUtils.rm_rf 'cache'
  end

  describe '#new' do
    it "sets default properties" do
      cache = WebCache.new
      expect(cache.life).to eq 3600
      expect(cache.dir).to eq 'cache'
    end

    it "accepts initialization properties" do
      cache = WebCache.new 'store', 120
      expect(cache.life).to eq 120
      expect(cache.dir).to eq 'store'
    end
  end

  describe '#get' do
    it "skips caching if disabled" do
      cache.disable
      cache.get url
      expect(Dir['cache/*']).to be_empty      
    end

    it "creates a cache folder" do
      expect(Dir).not_to exist 'cache'
      cache.get url
      expect(Dir).to exist 'cache'
    end

    it "saves a file" do
      cache.get url
      expect(Dir['cache/*']).not_to be_empty
    end

    it "downloads from the web" do
      expect(cache).to receive(:http_get).with(url)
      cache.get url
    end

    it "loads from cache" do
      cache.get url
      expect(cache).to be_cached url
      expect(cache).not_to receive(:http_get).with(url)
      expect(cache).to receive(:load_file_content)
      cache.get url
    end

    it "returns content from cache" do
      cache.get url
      expect(cache).to be_cached url
      response = cache.get url
      expect(response.content.length).to be > 500
    end

    context 'with invalid request' do
      let(:response) { cache.get 'http://example.com/not_found' }

      it 'returns the error message' do
        expect(response.content).to eq '404 Not Found'
      end

      it 'sets error to the error message' do
        expect(response.error).to eq '404 Not Found'
      end
    end

    context "with https" do
      let(:response) { cache.get 'https://bing.com' }

      before do
        cache.disable
      end

      it 'works' do
        expect(response.content.size).to be > 40000
        expect(response.error).to be nil
      end
    end
  end

  describe '#cached?' do
    it "returns true when url is cached" do
      cache.get url
      expect(cache).to be_cached url
    end

    it "returns false when url is not cached" do
      expect(cache).not_to be_cached 'http://never.downloaded.com'
    end
  end

  describe '#enable' do
    it "enables http calls" do
      cache.enable
      expect(cache).to be_enabled
      expect(cache).to receive(:http_get)
      cache.get url
    end
  end

  describe '#disable' do
    it "disables cache handling" do
      cache.disable
      expect(cache).not_to be_enabled
      expect(cache).to receive(:http_get).exactly(2).times
      expect(cache).not_to receive(:load_file_content)
      cache.get url
      cache.get url
    end
  end

  describe '#options' do
    it "returns a hash with default options" do
      expected = {
        allow_redirections: :all, 
        ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
      }
      expect(cache.options).to eq expected
    end

    it "allows adding options" do
      cache.options[:hello] = 'world'
      expected = {
        allow_redirections: :all, 
        ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
        hello: 'world'
      }
      expect(cache.options).to eq expected      
    end
  end

end