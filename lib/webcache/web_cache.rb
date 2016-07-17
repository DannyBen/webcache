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

    return load_file_content(path) if File.exist? path

    response = http_get(url)
    save_file_content(path, response) unless !response || response.error

    response
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

  private

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
      Response.new open(url, allow_redirections: :all)
    rescue => e
      Response.new error: e.message, base_uri: url, content: e.message
    end
  end

  def old?(path)
    life > 0 and File.exist?(path) and Time.new - File.mtime(path) >= life
  end
end
