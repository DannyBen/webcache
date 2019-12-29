WebCache
==================================================

[![Gem Version](https://badge.fury.io/rb/webcache.svg)](https://badge.fury.io/rb/webcache)
[![Build Status](https://travis-ci.com/DannyBen/webcache.svg?branch=master)](https://travis-ci.com/DannyBen/webcache)
[![Maintainability](https://api.codeclimate.com/v1/badges/022f555211d47d655988/maintainability)](https://codeclimate.com/github/DannyBen/webcache/maintainability)

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

WebCache can be used both as an instance, and as a static class.

```ruby
require 'webcache'

# Instance
cache = WebCache.new life: '3h'
response = cache.get 'http://example.com'

# Static
WebCache.life = '3h'
WebCache.get 'http://example.com'
```

The design intention is to provide both a globally available singleton
`WebCache` object, as well as multiple caching instances, with different
settings - depending on the use case.

Note that the examples in this README are all using the instance syntax, but
all methods are also available statically.

This is the basic usage pattern:

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
cache = WebCache.new dir: 'tmp/my_cache', life: '3d'
response = cache.get 'http://example.com'
```

Or later:

```ruby
cache = WebCache.new
cache.dir = 'tmp/my_cache'
cache.life = '4h'
response = cache.get 'http://example.com'
```

The `life` property accepts any of these formats:

```ruby
cache.life = 10     # 10 seconds
cache.life = '20s'  # 20 seconds
cache.life = '10m'  # 10 minutes
cache.life = '10h'  # 10 hours
cache.life = '10d'  # 10 days
```

Use the `cached?` method to check if a URL is cached:

```ruby
cache = WebCache.new
cache.cached? 'http://example.com'
# => false

response = cache.get 'http://example.com'
cache.cached? 'http://example.com'
# => true
```

Use `enable` and `disable` to toggle caching on and off:

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

Use `clear url` to remove a cached object if it exists:

```ruby
cache = WebCache.new
response = cache.get 'http://example.com'
cache.cached? 'http://example.com'
# => true

cache.clear 'http://example.com'
cache.cached? 'http://example.com'
# => false
```

Use `flush` to delete the entire cache directory:

```ruby
cache = WebCache.new
cache.flush
```

Use `force: true` to force download even if the object is cached:

```ruby
cache = WebCache.new
response = cache.get 'http://example.com', force: true
```

Authentication
--------------------------------------------------

To configure an authentication header, use the `auth` option. Similarly to
the other options, this can be set directly on the static class, on instance
initialization, or later on the instance:

```ruby
cache = WebCache.new auth: '...'
cache.get 'http://example.com'      # authenticated

cache = WebCache.new
cache.auth = '...'
cache.get 'http://example.com'      # authenticated

WebCache.auth = '...'
WebCache.get 'http://example.com'   # authenticated
```

For basic authentication, provide a hash:

```ruby
cache = WebCache.new auth: { user: 'user', pass: 's3cr3t' }
```

For other authentication headers, simply provide the header string:

```ruby
cache = WebCache.new auth: "Bearer t0k3n"
```



Response Object
--------------------------------------------------

The response object holds these properties:

### `response.content`

Contains the HTML content. In case of an error, this will include the
error message. The `#to_s` method of the response object also returns
the same content.


### `response.error`

In case of an error, this contains the error message, `nil` otherwise.

### `response.code`

Contains the HTTP code, or `nil` if there was a non-HTTP error.

### `response.success?`

A convenience method, returns true if `error` is empty.

### `response.base_uri`

Contains the actual address of the page. This is useful when the request
is redirected. For example, `http://example.com` will set the 
`base_uri` to `http://example.com/` (note the trailing slash).


---

For a similar gem that provides general purpose caching, see the 
[Lightly gem][2]


[1]: http://ruby-doc.org/stdlib-2.0.0/libdoc/open-uri/rdoc/OpenURI/OpenRead.html#method-i-open
[2]: https://github.com/DannyBen/lightly
