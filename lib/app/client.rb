require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'gql'
require 'json'

module App
  class Client < Sinatra::Base
    configure :development do
      $stdout.sync = true
      register Sinatra::Reloader

      ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
    end

    register Sinatra::ActiveRecordExtension

    get '/' do
      erb :index, locals: {
        queries: JSON.generate(queries),
        initial_query: JSON.generate([initial_query])
      }
    end

    post '/query' do
      content_type :json

      result =
        begin
          App::Graph.query params[:q]
        rescue => exc
          error_as_json exc
        end

      JSON.pretty_generate(result) rescue '{"error":"JSON generator error"}'
    end

    helpers do
      def error_as_json(exc)
        result = {
          error: {
            code: 999,
            type: exc.class.name.split('::').last.underscore
          }
        }

        result[:error][:message] = exc.message if ENV['DEBUG']
        result
      end

      def initial_query
        <<-QUERY.strip_heredoc
          person("kurtcobain") {
            id,
            first_name,
            last_name,
            memberships as band_memberships {
              edges {
                band_name,
                started_year,
                ended_year
              }
            },
            roles_in_bands {
              edges { name }
            }
          }
        QUERY
      end

      def queries
        [{
          name: 'Details on the first 10 songs',
          value: <<-QUERY.strip_heredoc
            {
              songs.take(10) {
                count,
                edges {
                  id,
                  slug,
                  type,
                  band_name,
                  title,
                  duration.human as length,
                  album_title,
                  track_number,
                  note,
                  writers { edges { name } } as written_by
                }
              }
            }
          QUERY
        }, {
          name: 'Everything you need to know about "Smells Like Teen Spririt"',
          value: <<-QUERY.strip_heredoc
            song("nirvana-smells-like-teen-spirit") {
              id,
              title,
              duration.human as length,
              note,
              band {
                id,
                name,
                memberships {
                  edges {
                    member {
                      id,
                      name,
                      roles_in_bands {
                        edges {
                          id,
                          name
                        }
                      }
                    },
                    started_year,
                    ended_year
                  }
                }
              },
              writers {
                edges {
                  id,
                  name
                }
              } as written_by,
              album {
                id,
                title,
                released_on.format("long"),
                duration.human as length,
                songs {
                  count,
                  edges {
                    id,
                    title,
                    track_number,
                    writers { edges }
                  }
                }
              },
              track_number
            }
          QUERY
        }, {
          name: 'Counts for each model',
          value: <<-QUERY.strip_heredoc
            {
              people { count },
              bands { count },
              albums { count },
              songs { count },
              roles { count }
            }
          QUERY
        }, {
          name: 'Details on all albums',
          value: <<-QUERY.strip_heredoc
            {
              albums {
                count,
                edges {
                  id,
                  band_name as artist,
                  title,
                  songs_count as tracks,
                  duration.human as length,
                  released_on.format("long")
                }
              }
            }
          QUERY
        }, {
          name: 'People by roles in bands',
          value: <<-QUERY.strip_heredoc
            {
              roles {
                edges {
                  id,
                  name,
                  members {
                    edges
                  }
                }
              }
            }
          QUERY
        }, {
          name: 'Schema Info (3 levels deep)',
          value: <<-QUERY.strip_heredoc
            schema {
              name,
              calls {
                count,
                edges {
                  id,
                  parameters,
                  result_class {
                    name,
                    calls { count },
                    fields { count }
                  }
                }
              },
              fields {
                count,
                edges {
                  id,
                  calls {
                    count,
                    edges {
                      id
                    }
                  },
                  fields {
                    count,
                    edges {
                      id
                    }
                  }
                }
              }
            }
          QUERY
        }]
      end
    end
  end
end
