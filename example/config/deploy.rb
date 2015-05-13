lock "3.4.0" # valid only for current version of Capistrano

set :application, "gql-demo"
set :log_level, :debug
set :keep_releases, 3

set :repo_url, "git@github.com:martinandert/gql.git"
set :repo_tree, "example"

set :buildpack_url, "https://github.com/heroku/heroku-buildpack-ruby.git#v137"
set :foreman_options, port: 3012, user: "deploy"
set :default_env, stack: "cedar-14"
