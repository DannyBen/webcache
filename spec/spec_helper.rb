require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'bundler'
Bundler.require :default, :development

def httpbin_host
  ENV['HTTPBIN_HOST'] || 'https://httpbin.org'
end
