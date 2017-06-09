# Running via Docker

Getting started is straight forward with Docker. This saves ensuring your development
machine has all the latest dependencies and compatible ruby versions.


## Locally: Docker Compose

Although you can run the image any way you like, we've designed it to work out
of the box via docker-compose for development or deployment to a single server.

Make sure to [configure the environment](Environment.md) first, or this won't work.

``` shell
docker-compose up
```
