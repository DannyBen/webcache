describe WebCache do
  let(:url) { 'http://example.com' }

  before { subject.flush }

  describe '#new' do
    it 'sets default properties' do
      expect(subject.life).to eq 3600
      expect(subject.dir).to eq 'cache'
    end

    context 'with arguments' do
      subject { described_class.new dir: 'store', life: 120, auth: auth }

      let(:auth) { { user: 'user', pass: 's3cr3t' } }

      it 'sets its properties' do
        expect(subject.life).to eq 120
        expect(subject.dir).to eq 'store'
        expect(subject.user).to eq auth[:user]
        expect(subject.pass).to eq auth[:pass]
      end
    end
  end

  describe '#get' do
    it 'saves a file' do
      subject.get url
      expect(Dir['cache/*']).not_to be_empty
    end

    it 'downloads from the web' do
      expect(subject).to receive(:http_get).with(url)
      subject.get url
    end

    it 'loads from cache' do
      subject.get url
      expect(subject).to be_cached url
      expect(subject).not_to receive(:http_get).with(url)
      expect(subject).to receive(:load_file_content)
      subject.get url
    end

    it 'returns content from cache' do
      subject.get url
      expect(subject).to be_cached url
      response = subject.get url
      expect(response.content.length).to be > 500
    end

    context 'with file permissions' do
      before do
        subject.permissions = 0o600
        FileUtils.rm_f tmp_path
      end

      let(:tmp_path) { '/tmp/webcache-test-file' }
      let(:file_mode) { File.stat(tmp_path).mode & 0o777 }

      it 'chmods the cache file after saving' do
        allow(subject).to receive(:get_path).with(url).and_return tmp_path
        subject.get url
        expect(file_mode).to eq 0o600
      end
    end

    context 'with force: true' do
      it 'always downloads a fresh copy' do
        subject.get url
        expect(subject).to be_cached url
        expect(subject).to receive(:http_get).with(url)
        subject.get url, force: true
      end
    end

    context 'when cache is disabled' do
      before { subject.disable }

      it 'skips caching' do
        subject.get url
        expect(Dir['cache/*']).to be_empty
      end
    end

    context 'when cache dir does not exist' do
      before { expect(Dir).not_to exist 'cache' }

      it 'creates it' do
        subject.get url
        expect(Dir).to exist 'cache'
      end
    end

    context 'when the request is successful' do
      let(:response) { subject.get url }

      it 'sets response content' do
        expect(response.content).to match 'Example Domain'
      end

      it 'sets response code' do
        expect(response.code).to eq 200
      end

      it 'sets response base_uri' do
        expect(response.base_uri).to be_a HTTP::URI
        expect(response.base_uri.to_s).to eq 'http://example.com/'
      end

      it 'sets error to nil' do
        expect(response.error).to be_nil
      end
    end

    context 'with 404 url' do
      let(:response) { subject.get 'http://example.com/not_found' }

      it 'returns the error message' do
        expect(response.content).to eq '404 Not Found'
      end

      it 'sets error to the error message' do
        expect(response.error).to eq '404 Not Found'
      end

      it 'sets code to 404' do
        expect(response.code).to eq 404
      end
    end

    context 'with a bad url' do
      let(:response) { subject.get 'http://not-a-uri' }

      it 'returns the error message' do
        expect(response.content).to match 'failed to connect'
      end

      it 'sets error to the error message' do
        expect(response.error).to match 'failed to connect'
      end
    end

    context 'with https' do
      let(:response) { subject.get 'https://en.wikipedia.org/wiki/HTTPS' }

      before { subject.disable }

      it 'downloads from the web' do
        expect(response.content.size).to be > 40_000
        expect(response.error).to be_nil
      end
    end

    context 'with basic authentication' do
      let(:response) { subject.get "#{httpbin_host}/basic-auth/user/pass" }

      context 'when the credentials are valid' do
        before { subject.auth = { user: 'user', pass: 'pass' } }

        it 'downloads from the web' do
          expect(response).to be_success
          content = JSON.parse response.content
          expect(content['authenticated']).to be true
        end
      end

      context 'when the credentials are invalid' do
        before { subject.auth = { user: 'user', pass: 'wrong-pass' } }

        it 'fails' do
          expect(response).not_to be_success
          expect(response.code).to eq 401
        end
      end
    end

    context 'with other authentication header' do
      let(:response) { subject.get "#{httpbin_host}/bearer" }

      before { subject.auth = 'Bearer t0k3n' }

      it 'downloads from the web' do
        expect(response).to be_success
        content = JSON.parse response.content
        expect(content['authenticated']).to be true
        expect(content['token']).to eq 't0k3n'
      end
    end
  end

  describe '#cached?' do
    it 'returns true when url is cached' do
      subject.get url
      expect(subject).to be_cached url
    end

    it 'returns false when url is not cached' do
      expect(subject).not_to be_cached 'http://never.downloaded.com'
    end
  end

  describe '#enable' do
    it 'enables http calls' do
      subject.enable
      expect(subject).to be_enabled
      expect(subject).to receive(:http_get)
      subject.get url
    end
  end

  describe '#disable' do
    it 'disables cache handling' do
      subject.disable
      expect(subject).not_to be_enabled
      expect(subject).to receive(:http_get).twice
      expect(subject).not_to receive(:load_file_content)
      subject.get url
      subject.get url
    end
  end

  describe '#clear' do
    before do
      subject.get url
      expect(Dir).not_to be_empty subject.dir
    end

    it 'removes a url cache file' do
      subject.clear url
      expect(Dir).to be_empty subject.dir
    end
  end

  describe '#flush' do
    before do
      subject.get url
      expect(Dir).not_to be_empty subject.dir
    end

    it 'deletes the entire cache directory' do
      subject.flush
      expect(Dir).not_to exist subject.dir
    end
  end

  describe '#life=' do
    it 'handles plain numbers' do
      subject.life = 11
      expect(subject.life).to eq 11
    end

    it 'handles 11s as seconds' do
      subject.life = '11s'
      expect(subject.life).to eq 11
    end

    it 'handles 11m as minutes' do
      subject.life = '11m'
      expect(subject.life).to eq 11 * 60
    end

    it 'handles 11h as hours' do
      subject.life = '11h'
      expect(subject.life).to eq 11 * 60 * 60
    end

    it 'handles 11d as days' do
      subject.life = '11d'
      expect(subject.life).to eq 11 * 60 * 60 * 24
    end
  end

  describe '#permissions=' do
    it 'sets file permissions' do
      subject.permissions = 0o600
      expect(subject.permissions).to eq 0o600
    end
  end
end
