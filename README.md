WebCache
==================================================

[![Gem](https://img.shields.io/gem/v/webcache.svg?style=flat-square)](https://rubygems.org/gems/webcache)
[![Travis](https://img.shields.io/travis/DannyBen/webcache.svg?style=flat-square)](https://travis-ci.org/DannyBen/webcache)
[![Code Climate](https://img.shields.io/codeclimate/github/DannyBen/webcache.svg?style=flat-square)](https://codeclimate.com/github/DannyBen/webcache)
[![Gemnasium](https://img.shields.io/gemnasium/DannyBen/webcache.svg?style=flat-square)](https://gemnasium.com/DannyBen/webcache)

---

WebCache provides a hassle-free caching for HTTP download.

---

Install
--------------------------------------------------

```
$ gem install webcache
```

Or with bundler:

```ruby
gem 'webcache'
```

Usage
--------------------------------------------------

Use `WebCache.get url` to load from cache, or download:

```ruby
require 'webcache'
cache = WebCache.new
content = cache.get 'http://example.com'
```

By default, the cached objects are stored in the `./cache` folder, and
expire after 60 minutes. The cache folder will be created as needed.

You can change these settings on initialization:

```ruby
cache = WebCache.new 'tmp/my_cache', 7200
content = cache.get 'http://example.com'
```

Or later:

```ruby
cache = WebCache.new
cache.dir = 'tmp/my_cache'
cache.life = 7200 # seconds
content = cache.get 'http://example.com'
```

To check if a URL is cached, use the `cached?` method:

```ruby
cache = WebCache.new
cache.cached? 'http://example.com'
# => false

content = cache.get 'http://example.com'
cache.cached? 'http://example.com'
# => true
```

You can enable/disable the cache at any time:

```ruby
cache = WebCache.new
cache.disable
cache.enabled? 
# => false

content = cache.get 'http://example.com'
cache.cached? 'http://example.com'
# => false

cache.enable
content = cache.get 'http://example.com'
cache.cached? 'http://example.com'
# => true
```

Error Handling
--------------------------------------------------

Whenever a request results in any HTTP error, two things will happen:

1. The return value will be set to the error message
2. The `last_error` variable will be set to the error message

If `last_error` is anything but `false`, it means failure.

```ruby
cache = WebCache.new
puts cache.get 'http://example.com/not_found'
# => '404 Not Found'

puts cache.last_error
# => '404 Not Found'
```
