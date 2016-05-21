require 'digest/md5'
require 'fileutils'
require 'open-uri'

class WebCache
  attr_accessor :dir, :life

  def initialize(dir='cache', life=60)
    @dir = dir
    @life = life
    @enabled = true
    FileUtils.mkdir_p dir
  end

  def get(url)
    return http_get url unless enabled?

    path = get_path url
    FileUtils.rm path if old? path
    return load_file_content path if File.exist? path

    content = http_get(url)
    save_file_content(path, content)
    content
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
    @last_url = url
    File.join dir, Digest::MD5.hexdigest(url)
  end

  def load_file_content(path)
    Marshal.load File.binread(path)
  end

  def save_file_content(path, content)
    File.open path, 'wb' do |f| 
      f.write Marshal.dump content
    end
  end

  def http_get(url)
    open(url).read
  end

  def old?(path)
    life > 0 and File.exist?(path) and Time.new - File.mtime(path) >= life
  end
end
