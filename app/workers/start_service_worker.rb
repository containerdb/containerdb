class StartServiceWorker

  include Sidekiq::Worker

  def perform(service_id)
    service = Service.find(service_id)

    return if service.container_id
    fail 'Cannot be performed on an external service' unless service.hosted?

    # @note disabled as it's just hanging
    #Rails.logger.info("Pulling Image #{service.image} for Service ##{service.id}")
    #image = Docker::Image.create(
    #  'fromImage' => service.image,
    #)

    #Rails.logger.info("Pulled Image #{service.image} for Service ##{service.id}")
    #Rails.logger.debug(image)

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
            }
          ]
        }
      }
    )

    Rails.logger.info("Starting Container #{container.id} for Service ##{service.id}")

    begin
      if container.tap(&:start).wait(60)['StatusCode'].zero?
        service.update!(container_id: container.id)
        Rails.logger.info("Finished starting Container #{container.id} for Service ##{service.id}")
      else
        Rails.logger.error("Container failed to start for Service ##{service.id}")
      end
    rescue Docker::Error::TimeoutError => e
      Rails.logger.error("Container timed out for Service ##{service.id}")
      Rails.logger.debug(e)
    end

    Rails.logger.debug(container)
  end
end
