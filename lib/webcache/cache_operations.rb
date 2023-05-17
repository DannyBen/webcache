require 'digest/md5'
require 'fileutils'
require 'http'

class WebCache
  module CacheOperations
    attr_accessor :permissions
    attr_reader :last_error, :user, :pass, :auth
    attr_writer :dir

    def initialize(dir: 'cache', life: '1h', auth: nil, permissions: nil)
      @dir = dir
      @life = life_to_seconds life
      @enabled = true
      @auth = convert_auth auth
      @permissions = permissions
    end

    def get(url, force: false)
      return http_get url unless enabled?

      path = get_path url
      clear url if force || stale?(path)

      get! path, url
    end

    def life
      @life ||= 3600
    end

    def life=(new_life)
      @life = life_to_seconds new_life
    end

    def dir
      @dir ||= 'cache'
    end

    def cached?(url)
      path = get_path url
      File.exist?(path) and !stale?(path)
    end

    def enabled?
      @enabled ||= (@enabled.nil? ? true : @enabled)
    end

    def enable
      @enabled = true
    end

    def disable
      @enabled = false
    end

    def clear(url)
      path = get_path url
      FileUtils.rm path if File.exist? path
    end

    def flush
      FileUtils.rm_rf dir if Dir.exist? dir
    end

    def auth=(auth)
      convert_auth auth
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
      File.open path, 'wb', permissions do |file|
        file.write Marshal.dump(response)
      end
    end

    def http_get(url)
      Response.new http_response(url)
    rescue => e
      url = URI.parse url
      Response.new error: e.message, base_uri: url, content: e.message
    end

    def basic_auth?
      !!(user and pass)
    end

    def http_response(url)
      if basic_auth?
        HTTP.basic_auth(user: user, pass: pass).follow.get url
      elsif auth
        HTTP.auth(auth).follow.get url
      else
        HTTP.follow.get url
      end
    end

    def stale?(path)
      life.positive? and File.exist?(path) and Time.new - File.mtime(path) >= life
    end

    def life_to_seconds(arg)
      arg = arg.to_s

      case arg[-1]
      when 's' then arg[0..].to_i
      when 'm' then arg[0..].to_i * 60
      when 'h' then arg[0..].to_i * 60 * 60
      when 'd' then arg[0..].to_i * 60 * 60 * 24
      else; arg.to_i
      end
    end

    def convert_auth(opts)
      @user = nil
      @pass = nil
      @auth = nil

      if opts.respond_to?(:has_key?) && opts.has_key?(:user) && opts.has_key?(:pass)
        @user = opts[:user]
        @pass = opts[:pass]
      else
        @auth = opts
      end
    end
  end
end
