require 'rubygems'
require 'bundler'

Bundler.require

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'app'

run App::Client.new
