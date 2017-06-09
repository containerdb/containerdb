# Running via Docker

Getting started is straight forward with Docker. This saves ensuring your development
machine has all the latest dependencies and compatible ruby versions.


## Development

A postgres database and a redis database will be required for the connection. Here a couple of examples:

``` shell
docker run -ti -v /var/lib/postgresql/data -p 5432:5432 -e "POSTGRES_DB=containerdb_production" --rm --name containerdb-postgres postgres
```

``` shell
docker run -ti -p 6739:6739 --name containerdb-redis redis

Running the actual application is simple enough:

``` shell
docker run --env-file .env.production -ti -a STDOUT -a STDERR -p 5000:5000 --rm --name containerdb containerdb/containerdb
```

The sidekiq commands can be ran the same,  but pass in a custom command like:

``` shell
... containerdb/containerdb bundle exec sidekiq -c 10 -q default
```
