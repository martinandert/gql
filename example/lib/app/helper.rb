require 'active_record'
require 'gql'

module App
  module Helper
    def error_as_json(exc)
      case exc
      when GQL::Error
        exc.as_json
      when ActiveRecord::RecordNotFound
        generic_error_as_json exc, 404
      when ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved, ActiveRecord::RecordNotDestroyed
        info =
          if exc.record && exc.record.errors.any?
            { failed_validations: exc.record.errors.full_messages }
          else
            {}
          end

        generic_error_as_json exc, 422, info
      else
        generic_error_as_json exc
      end
    end

    def generic_error_as_json(exc, code = 900, info = {})
      result = {
        error: {
          code: code,
          type: exc.class.name.split('::').last.titleize.downcase
        }.merge(info)
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
                writers as written_by { edges { name } }
              }
            }
          }
        QUERY
      }, {
        name: 'Smells Like Teen Spirit',
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
            writers as written_by {
              edges {
                id,
                name
              }
            },
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
                  writers { edges { name } }
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
                  edges {
                    id,
                    name
                  }
                }
              }
            }
          }
        QUERY
      }, {
        name: 'Add a new person',
        value: <<-QUERY.strip_heredoc
          create_person(<record>) {
            id,
            name
          }

          // a variable used as call argument
          <record> = {
            "slug":       "eddievedder",
            "first_name": "Eddie",
            "last_name":  "Vedder"
          }
        QUERY
      }, {
        name: 'Assign a person to a band',
        value: <<-QUERY.strip_heredoc
          assign_person_to_band(<person>, <band>, <started>, <ended>, <roles>) {
            member {
              id,
              name
            },
            band {
              id,
              name
            },
            started_year,
            ended_year,
            roles {
              edges {
                name
              }
            }
          }

          // arguments for the call
          <person>  = "eddievedder"
          <band>    = "pearljam"
          <started> = 1990
          <ended>   = null
          <roles>   = ["lead-vocals", "guitar"]
        QUERY
      }, {
        name: 'Schema: All root calls',
        value: <<-QUERY.strip_heredoc
          {
            __type__ {
              calls {
                edges {
                  id,
                  parameters,
                  result_class
                }
              }
            }
          }
        QUERY
      }, {
        name: 'Schema: All root fields',
        value: <<-QUERY.strip_heredoc
          {
            __type__ {
              fields {
                edges {
                  id
                }
              }
            }
          }
        QUERY
      }, {
        name: 'Schema info (first three levels)',
        value: <<-QUERY.strip_heredoc
          {
            __type__ {
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
                  name,
                  calls {
                    count,
                    edges {
                      id
                    }
                  },
                  fields {
                    count,
                    edges {
                      id,
                      name,
                      fields {
                        edges {
                          id,
                          name
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        QUERY
      }, {
        name: "Syntax error",
        value: <<-QUERY.strip_heredoc


          foo() {
            bar,
            baz, // <-- bad comma
          }

        QUERY
      }, {
        name: "Unknown field",
        value: <<-QUERY.strip_heredoc
          person("kurtcobain") {
            first_name,
            zodiac_sign // <-- undefined field
          }
        QUERY
      }, {
        name: "Unknown call",
        value: <<-QUERY.strip_heredoc
          person("kurtcobain") {
            first_name.reverse // <-- undefined call
          }
        QUERY
      }, {
        name: 'You',
        value: <<-QUERY.strip_heredoc
          /*
           * shows context usage
           */

          you {
            ip_address,
            queries_count
          }
        QUERY
      }]
    end

    extend self
  end
end
