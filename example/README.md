# gql Demo Application

This directory contains a small web application that shows how to use gql.

Properties:

* Sinatra as web framework
* Sqlite3 as database (in development)
* ActiveRecord for models (see `lib/app/models`)
* all GQL field and call definitions can be found under `lib/app/graph`

Run `bin/console` for an interactive prompt (loaded with example models/data).

To start the web application, run `bin/rackup`.

Don't forget to set a `DATABASE_URL` environment variable. To use the pre-populated sqlite3 database, set this variable to `sqlite3:////path/to/db/app.sqlite3`.

To access the `schema` root call and to see debug output, set the `DEBUG` environment variable.

To see the running web application in action, visit http://gql-demo.herokuapp.com/
