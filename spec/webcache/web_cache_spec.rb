require 'spec_helper'
require 'fileutils'

describe WebCache do
  let(:url) { 'http://example.com' }

  before do 
    FileUtils.rm_rf 'cache'
  end

  describe '#new' do
    it "sets default properties" do
      expect(subject.life).to eq 3600
      expect(subject.dir).to eq 'cache'
    end

    context "with arguments" do
      subject { described_class.new dir: 'store', life: 120 }

      it "sets its properties" do
        expect(subject.life).to eq 120
        expect(subject.dir).to eq 'store'
      end
    end
  end

  describe '#get' do
    it "saves a file" do
      subject.get url
      expect(Dir['cache/*']).not_to be_empty
    end

    it "downloads from the web" do
      expect(subject).to receive(:http_get).with(url)
      subject.get url
    end

    it "loads from cache" do
      subject.get url
      expect(subject).to be_cached url
      expect(subject).not_to receive(:http_get).with(url)
      expect(subject).to receive(:load_file_content)
      subject.get url
    end

    it "returns content from cache" do
      subject.get url
      expect(subject).to be_cached url
      response = subject.get url
      expect(response.content.length).to be > 500
    end

    context "when cache is disabled" do
      before { subject.disable }

      it "skips caching" do
        subject.get url
        expect(Dir['cache/*']).to be_empty      
      end
    end

    context "when cache dir does not exist" do
      before { expect(Dir).not_to exist 'cache' }

      it "creates it" do
        subject.get url
        expect(Dir).to exist 'cache'
      end
    end

    context 'with invalid request' do
      let(:response) { subject.get 'http://example.com/not_found' }

      it 'returns the error message' do
        expect(response.content).to eq '404 Not Found'
      end

      it 'sets error to the error message' do
        expect(response.error).to eq '404 Not Found'
      end
    end

    context "with https" do
      let(:response) { subject.get 'https://en.wikipedia.org/wiki/HTTPS' }

      before { subject.disable }

      it 'works' do
        expect(response.content.size).to be > 40000
        expect(response.error).to be nil
      end
    end
  end

  describe '#cached?' do
    it "returns true when url is cached" do
      subject.get url
      expect(subject).to be_cached url
    end

    it "returns false when url is not cached" do
      expect(subject).not_to be_cached 'http://never.downloaded.com'
    end
  end

  describe '#enable' do
    it "enables http calls" do
      subject.enable
      expect(subject).to be_enabled
      expect(subject).to receive(:http_get)
      subject.get url
    end
  end

  describe '#disable' do
    it "disables cache handling" do
      subject.disable
      expect(subject).not_to be_enabled
      expect(subject).to receive(:http_get).exactly(2).times
      expect(subject).not_to receive(:load_file_content)
      subject.get url
      subject.get url
    end
  end

  describe '#options' do
    it "returns a hash with default options" do
      expected = {
        allow_redirections: :all, 
        ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
      }
      expect(subject.options).to eq expected
    end

    it "allows adding options" do
      subject.options[:hello] = 'world'

      expected = {
        allow_redirections: :all, 
        ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
        hello: 'world'
      }
      expect(subject.options).to eq expected      
    end
  end

  describe '#life=', :focus do    
    it "handles plain numbers" do
      subject.life = 11
      expect(subject.life).to eq 11
    end

    it "handles 11s as seconds" do
      subject.life = '11s'
      expect(subject.life).to eq 11
    end

    it "handles 11m as minutes" do
      subject.life = '11m'
      expect(subject.life).to eq 11 * 60
    end

    it "handles 11h as hours" do
      subject.life = '11h'
      expect(subject.life).to eq 11 * 60 * 60
    end

    it "handles 11d as days" do
      subject.life = '11d'
      expect(subject.life).to eq 11 * 60 * 60 * 24
    end
  end

end