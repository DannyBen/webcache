require 'digest/md5'
require 'fileutils'
require 'open-uri'

class WebCache
  attr_reader :last_error
  attr_accessor :dir, :life

  def initialize(dir='cache', life=3600)
    @dir = dir
    @life = life
    @enabled = true
  end

  def get(url)
    @last_error = false
    return http_get url unless enabled?

    path = get_path url
    FileUtils.rm path if old? path
    return load_file_content path if File.exist? path

    content = http_get(url)
    if @last_error
      content = @last_error
    else
      save_file_content(path, content)
    end

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
    File.join dir, Digest::MD5.hexdigest(url)
  end

  def load_file_content(path)
    Marshal.load File.binread(path)
  end

  def save_file_content(path, content)
    FileUtils.mkdir_p dir
    File.open path, 'wb' do |f| 
      f.write Marshal.dump content
    end
  end

  def http_get(url)
    begin
      open(url).read
    rescue OpenURI::HTTPError => e
      @last_error = e.message
    end
  end

  def old?(path)
    life > 0 and File.exist?(path) and Time.new - File.mtime(path) >= life
  end
end
