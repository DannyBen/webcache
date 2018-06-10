WebCache
==================================================

[![Gem Version](https://badge.fury.io/rb/webcache.svg)](https://badge.fury.io/rb/webcache)
[![Build Status](https://travis-ci.com/DannyBen/webcache.svg?branch=master)](https://travis-ci.com/DannyBen/webcache)
[![Maintainability](https://api.codeclimate.com/v1/badges/022f555211d47d655988/maintainability)](https://codeclimate.com/github/DannyBen/webcache/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/022f555211d47d655988/test_coverage)](https://codeclimate.com/github/DannyBen/webcache/test_coverage)

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


Basic Authentication and Additional Options
--------------------------------------------------
WebCache uses Ruby's [Open URI][1] to download. If you wish to modify 
the options it uses, simply update the `options` hash.

For example, to use HTTP basic authentication, use something like this:

```ruby
cache = WebCache.new
cache.options[:http_basic_authentication] = ["user", "pass123!"]
response = cache.get 'http://example.com'
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


### `response.base_uri`

Contains the actual address of the page. This is useful when the request
is redirected. For example, `http://example.com` will set the 
`base_uri` to `http://example.com/` (note the trailing slash).


---

For a similar gem that provides general purpose caching, see the 
[Lightly gem][2]


[1]: http://ruby-doc.org/stdlib-2.0.0/libdoc/open-uri/rdoc/OpenURI/OpenRead.html#method-i-open
[2]: https://github.com/DannyBen/lightly