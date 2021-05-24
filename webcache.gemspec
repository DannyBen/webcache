lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'date'
require 'webcache/version'

Gem::Specification.new do |s|
  s.name        = 'webcache'
  s.version     = WebCache::VERSION
  s.date        = Date.today.to_s
  s.summary     = "Hassle-free caching for HTTP download"
  s.description = "Easy to use file cache for web downloads"
  s.authors     = ["Danny Ben Shitrit"]
  s.email       = 'db@dannyben.com'
  s.files       = Dir['README.md', 'lib/**/*.*']
  s.homepage    = 'https://github.com/DannyBen/webcache'
  s.license     = 'MIT'
  s.required_ruby_version = ">= 2.5.0"

  s.add_runtime_dependency 'http', '~> 5.0'
end
