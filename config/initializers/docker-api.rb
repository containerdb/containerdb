require "docker"

# Set the host: https://github.com/swipely/docker-api#host
# Set SSL certs: https://github.com/swipely/docker-api#ssl

Rails.logger.info("Connected to Docker daemon on #{Docker.url}")
