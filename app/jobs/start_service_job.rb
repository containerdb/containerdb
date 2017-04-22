class StartServiceJob < ApplicationJob
  def perform(service)
    return if service.container_id
    fail 'Cannot be performed on an external service' unless service.hosted?

    Rails.logger.info("Pulling Image #{service.image} for Service ##{service.id}")
    image = Docker::Image.create(
      'fromImage' => service.image,
    )

    Rails.logger.info("Pulled Image #{service.image} for Service ##{service.id}")
    Rails.logger.debug(image)
    Rails.logger.info("Creating Container for Service ##{service.id}")

    container = Docker::Container.create(
      'name' => "#{service.image.parameterize}-#{service.id}",
      'Image' => service.image,
      'Env' => service.container_env,
      'ExposedPorts' => {
        "#{service.service.container_port}/tcp" => {},
      },
      'HostConfig' => {
        'PortBindings' => {
          "#{service.service.container_port}/tcp" => [
            {
              'HostPort' => service.port.to_s,
            },
          ]
        },
      },
    )

    Rails.logger.info("Starting Container #{container.id} for Service ##{service.id}")
    container.start

    Rails.logger.info("Waiting for Container #{container.id} for Service ##{service.id}")
    container.wait
    Rails.logger.info("Started Container #{container.id} for Service ##{service.id}")

    service.update!(container_id: container.id)
    Rails.logger.debug(container)
  end
end
