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
      expect(cache.life).to eq 60
      expect(cache.dir).to eq 'cache'
    end

    it "accepts initialization properties" do
      cache = WebCache.new 'store', 120
      expect(cache.life).to eq 120
      expect(cache.dir).to eq 'store'
    end

    it "creates a cache folder" do
      FileUtils.rm_rf 'cache'
      expect(Dir).not_to exist 'cache'
      cache = WebCache.new
      expect(Dir).to exist 'cache'
    end
  end

  describe '#get' do
    it "skips caching if disabled" do
      cache.disable
      cache.get url
      expect(Dir['cache/*']).to be_empty      
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
      content = cache.get url
      expect(content.length).to be > 500
    end

    context 'with invalid request' do
      let(:url) { 'http://example.com/not_found' }

      it 'returns the error message' do
        expect(cache.get url).to eq '404 Not Found'
      end

      it 'sets last_error to the error message' do
        cache.get url
        expect(cache.last_error).to eq '404 Not Found'
      end
    end

    context 'with a valid request following an invalid one' do
      let(:invalid_url) { 'http://example.com/not_found' }

      it 'resets last_error' do
        cache.get invalid_url
        expect(cache.last_error).to eq '404 Not Found'
        cache.get url
        expect(cache.last_error).to be false
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
    it "enables cache handling" do
      cache.enable
      expect(cache).to be_enabled
      expect(cache).to receive(:http_get)
      cache.get url
      expect(cache).to receive(:load_file_content)
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

end