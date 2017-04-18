require "docker"

Docker.url = ENV['DOCKER_HOST'].presence || "unix:///var/run/docker.sock"

if ENV['DOCKER_CERT_PATH'].present?
  cert_path = ENV['DOCKER_CERT_PATH']
  Docker.options = {
    client_cert: File.join(cert_path, 'cert.pem'),
    client_key: File.join(cert_path, 'key.pem'),
    ssl_ca_file: File.join(cert_path, 'ca.pem'),
    scheme: 'https',
  }
end

Rails.logger.info("Connected to Docker daemon on #{Docker.url}")
