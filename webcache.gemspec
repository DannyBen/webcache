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
  s.required_ruby_version = ">= 2.2.2"

  s.add_runtime_dependency 'open_uri_redirections', '~> 0.2'

  s.add_development_dependency 'runfile', '~> 0.10'
  s.add_development_dependency 'runfile-tasks', '~> 0.4'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'simplecov', '~> 0.15'
  s.add_development_dependency 'byebug', '~> 10.0'
end
