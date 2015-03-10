# gql

[![Build Status](https://travis-ci.org/martinandert/gql.svg?branch=master)](https://travis-ci.org/martinandert/gql)
[![Code Climate](https://codeclimate.com/github/martinandert/gql/badges/gpa.svg)](https://codeclimate.com/github/martinandert/gql)
[![Test Coverage](https://codeclimate.com/github/martinandert/gql/badges/coverage.svg)](https://codeclimate.com/github/martinandert/gql)
[![Dependency Status](https://gemnasium.com/martinandert/gql.svg)](https://gemnasium.com/martinandert/gql)

A Ruby implementation of Facebook's yet-to-be-released GraphQL specification, inspired by [graphql-ruby](https://github.com/rmosolgo/graphql-ruby), but with other/more/less features/bugs.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gql'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```
$ gem install gql
```


## Usage

TODO: Write usage instructions here


## Example

Run `bin/console` for an interactive prompt (loaded with example models/data) and enter the following:

```ruby
puts query(<<-QUERY_STRING).to_json
  user(<token>) {
    id,
    is_admin,
    full_name as name,
    created_at { year, month } as created_year_and_month,
    created_at.format("long") as created,
    account {
      bank_name,
      iban,
      saldo as saldo_string,
      saldo {
        currency,
        cents   /* silly block comment */
      }
    },
    albums.first(2) {
      count,
      edges {
        cursor,
        node {
          artist,
          title,
          songs.first(2) {
            edges {
              id,
              title.upcase as upcased_title,
              title.upcase.length as upcased_title_length
            }
          }
        }
      }
    }
  }

  <token> = "ma"  // a variable
QUERY_STRING
```

This should result in the following JSON (after prettyfication):

```json
{
  "id": "ma",
  "is_admin": true,
  "name": "Martin Andert",
  "created_year_and_month": {
    "year": 2010,
    "month": 3
  },
  "created": "March 05, 2010 20:14",
  "account": {
    "bank_name": "Foo Bank",
    "iban": "987654321",
    "saldo_string": "100000.00 EUR",
    "saldo": {
      "currency": "EUR",
      "cents": 10000000
    }
  },
  "albums": {
    "count": 2,
    "edges": [
      {
        "cursor": 1,
        "node": {
          "artist": "Metallica",
          "title": "Black Album",
          "songs": {
            "edges": [
              {
                "id": 1,
                "upcased_title": "ENTER SANDMAN",
                "upcased_title_length": 13
              }, {
                "id": 2,
                "upcased_title": "SAD BUT TRUE",
                "upcased_title_length": 12
              }
            ]
          }
        }
      }, {
        "cursor": 2,
        "node": {
          "artist": "Nirvana",
          "title": "Nevermind",
          "songs": {
            "edges": [
              {
                "id": 5,
                "upcased_title": "SMELLS LIKE TEEN SPIRIT",
                "upcased_title_length": 23
              }, {
                "id": 6,
                "upcased_title": "COME AS YOU ARE",
                "upcased_title_length": 15
              }
            ]
          }
        }
      }
    ]
  }
}
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.


## Contributing

1. Fork it ( https://github.com/martinandert/gql/fork )
2. Run `bin/setup` to install dependencies.
3. Run the tests. We only take pull requests with passing tests, and it's great to know that you have a clean slate: `bin/rake test`.
4. Create your feature branch (`git checkout -b my-new-feature`)
5. Add a test for your change. Only refactoring and documentation changes require no new tests. If you are adding functionality or are fixing a bug, we need a test!
6. Make the test pass.
7. Commit your changes (`git commit -am 'add some feature'`)
8. Push to your fork (`git push origin my-new-feature`)
9. Create a new Pull Request


## License

Released under The MIT License.
