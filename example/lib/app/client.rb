require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/activerecord'

module App
  class Client < Sinatra::Base
    configure :development do
      $stdout.sync = true
      register Sinatra::Reloader
    end

    register Sinatra::ActiveRecordExtension
    set :database, App::CONNECTION_SPEC

    get '/' do
      'Hello, World!'
    end
  end
end
