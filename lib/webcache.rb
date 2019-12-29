require 'openssl'

require 'webcache/polyfills'
require 'webcache/cache_operations'
require 'webcache/response'
require 'webcache/web_cache'

if ENV['BYEBUG']
  require 'byebug'
  require 'lp'
end

