# gql demo application

This directory contains a small web application that shows how to use the gql gem.

Synopsis:

* Sinatra as web framework
* Sqlite3 as database (in development)
* ActiveRecord as ORM (see `lib/app/models`)
* GQL field and call definitions can be found under `lib/app/graph`

Run `bin/console` for an interactive prompt (loaded with example models/data).

To start the web application, run `bin/rackup`.

Don't forget to set a `DATABASE_URL` environment variable. To use the pre-populated sqlite3 database, set this variable to `sqlite3:db/app.sqlite3`.

To get access to the schema through the `__type__` field and to see debug output, set the `DEBUG` environment variable:

```sh
$ DEBUG=1 bin/console
$ DEBUG=1 bin/rackup
```

To see the running web application in action, visit http://gql-demo.herokuapp.com/
