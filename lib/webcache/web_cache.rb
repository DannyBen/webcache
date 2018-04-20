require 'digest/md5'
require 'fileutils'
require 'open-uri'
require 'open_uri_redirections'

class WebCache
  attr_reader :last_error
  attr_accessor :dir, :life

  def initialize(dir='cache', life=3600)
    @dir = dir
    @life = life
    @enabled = true
  end

  def get(url)
    return http_get url unless enabled?

    path = get_path url
    FileUtils.rm path if old? path

    get! path, url
  end

  def cached?(url)
    path = get_path url
    File.exist?(path) and !old?(path)
  end

  def enabled?
    @enabled
  end

  def enable
    @enabled = true
  end

  def disable
    @enabled = false
  end

  def options
    @options ||= default_open_uri_options
  end

  private

  def get!(path, url)
    return load_file_content path if File.exist? path
    response = http_get url
    save_file_content path, response unless !response || response.error
    response
  end

  def get_path(url)
    File.join dir, Digest::MD5.hexdigest(url)
  end

  def load_file_content(path)
    Marshal.load File.binread(path)
  end

  def save_file_content(path, response)
    FileUtils.mkdir_p dir
    File.open path, 'wb' do |f| 
      f.write Marshal.dump response
    end
  end

  def http_get(url)
    begin
      Response.new open(url, options)
    rescue => e
      Response.new error: e.message, base_uri: url, content: e.message
    end
  end

  def old?(path)
    life > 0 and File.exist?(path) and Time.new - File.mtime(path) >= life
  end

  # Use a less strict URL retrieval:
  # 1. Allow http to/from https redirects (through the use of the 
  #    open_uri_redirections gem)
  # 2. Disable SSL verification, otherwise, some https sites that show 
  #    properly in the browser, will return an error.
  def default_open_uri_options
    {
      allow_redirections: :all, 
      ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
  end
end
