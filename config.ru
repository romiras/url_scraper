require 'rubygems'
require 'bundler'

Bundler.require 

require 'resque'
require 'resque/server'

require './app'

use Rack::ShowExceptions

# run App
run Rack::URLMap.new \
     "/" => App.new,
     "/resque" => Resque::Server.new

