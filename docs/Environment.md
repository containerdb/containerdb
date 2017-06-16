# Environment

Certain variables are required/desired for containerdb to function correctly.


## Core

The core application requires a few things to work correctly. The easiest is
to set these the web server environment system, or locally for testing via
adding a `.env.production` file which will automatically be used.

| Key                         | Description                                    | Required?     |
|-----------------------------|------------------------------------------------|---------------|
| SECRET_KEY_BASE             | Required by Rails for secrets encryption       | Yes           |
| DATABASE_URL                | Database connection string                     | Yes           |
| REDIS_URL                   | Redis connection string                        | Yes           |


## Web Server

The help fine-tune the server to your specific needs, for performance or flexibility.

| Key                         | Description                                    | Required?     |
|-----------------------------|------------------------------------------------|---------------|
| WEB_CONCURRENCY             | Number of puma "workers" to spawn              | No            |
| RAILS_LOG_TO_STDOUT         | Log to STDOUT rather than log/production.log   | No            |
| RAILS_SERVE_STATIC_FILES    | Required if you serve the app directly         | No            |
