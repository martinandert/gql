require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'gql'
require 'json'

module App
  class Client < Sinatra::Base
    register Sinatra::ActiveRecordExtension
    enable :sessions

    configure :development do
      $stdout.sync = true
      register Sinatra::Reloader
      ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
    end

    get '/' do
      erb :index, locals: {
        queries: JSON.generate(Helper.queries),
        initial_query: JSON.generate([Helper.initial_query])
      }
    end

    post '/query' do
      content_type :json

      context = { ip_address: request.ip, queries_count: queries_count }

      result =
        begin
          GQL.execute params[:q], context
        rescue => exc
          Helper.error_as_json exc
        end

      result = [result] unless result.respond_to?(:each)

      JSON.pretty_generate result
    end

    helpers do
      def queries_count
        session[:queries_count] ||= 0
        session[:queries_count] += 1
      end
    end
  end
end
