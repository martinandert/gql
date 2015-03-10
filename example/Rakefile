$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'sinatra/activerecord/rake'

namespace :db do
  task :load_config do
    require 'app'

    # needed for loading fixtures
    include App::Models

    # hook sinatra-activerecord registration
    App::Client
  end
end
