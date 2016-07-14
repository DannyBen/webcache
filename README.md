WebCache
==================================================

[![Gem](https://img.shields.io/gem/v/webcache.svg?style=flat-square)](https://rubygems.org/gems/webcache)
[![Travis](https://img.shields.io/travis/DannyBen/webcache.svg?style=flat-square)](https://travis-ci.org/DannyBen/webcache)
[![Code Climate](https://img.shields.io/codeclimate/github/DannyBen/webcache.svg?style=flat-square)](https://codeclimate.com/github/DannyBen/webcache)
[![Gemnasium](https://img.shields.io/gemnasium/DannyBen/webcache.svg?style=flat-square)](https://gemnasium.com/DannyBen/webcache)

---

Hassle-free caching for HTTP download.

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

Load a file from cache, or download if needed:

```ruby
require 'webcache'
cache = WebCache.new
response = cache.get 'http://example.com'
puts response             # => "<html>...</html>"
puts response.content     # => same as above
puts response.to_s        # => same as above
puts response.error       # => nil
puts response.base_uri    # => "http://example.com/"
```

By default, the cached objects are stored in the `./cache` directory, and
expire after 60 minutes. The cache directory will be created as needed.

You can change these settings on initialization:

```ruby
cache = WebCache.new 'tmp/my_cache', 7200
response = cache.get 'http://example.com'
```

Or later:

```ruby
cache = WebCache.new
cache.dir = 'tmp/my_cache'
cache.life = 7200 # seconds
response = cache.get 'http://example.com'
```

To check if a URL is cached, use the `cached?` method:

```ruby
cache = WebCache.new
cache.cached? 'http://example.com'
# => false

response = cache.get 'http://example.com'
cache.cached? 'http://example.com'
# => true
```

You can enable/disable the cache at any time:

```ruby
cache = WebCache.new
cache.disable
cache.enabled? 
# => false

response = cache.get 'http://example.com'
cache.cached? 'http://example.com'
# => false

cache.enable
response = cache.get 'http://example.com'
cache.cached? 'http://example.com'
# => true
```

Response Object
--------------------------------------------------

The response object holds these properties:

**`response.content`**:  
Contains the HTML content. In case of an error, this will include the
error message. The `#to_s` method of the response object also returns
the same content.

**`response.error`**:  
In case of an error, this contains the error message, `nil` otherwose.

**`response.base_uri`**:  
Contains the actual address of the page. This is useful when the request
is redirected. For example, `http://example.com` will set the 
`base_uri` to `http://example.com/` (note the trailing slash).


```ruby
cache = WebCache.new
response = cache.get 'http://example.com/not_found'
puts response
# => '404 Not Found'

puts response.error
# => '404 Not Found'
```
