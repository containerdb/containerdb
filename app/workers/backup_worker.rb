class BackupWorker

  include Sidekiq::Worker

  def perform(backup_id)
    backup = Backup.find(backup_id)

    Rails.logger.info("Starting backup for #{backup.service.id}")

    backup_storage_provider = backup.service.backup_storage_provider
    unless backup_storage_provider.present?
      backup.failed!
      return false
    end

    backup.running!

    # Pull the backup image
    Rails.logger.info("Pulling containerdb/backup-restore")
    image = Docker::Image.create('fromImage' => 'containerdb/backup-restore')
    Rails.logger.info(image)

    file_name = backup.service.backup_file_name
    environment_variables = backup.service.backup_environment_variables.merge({
      FILE_NAME: file_name,
      BACKUP_PROVIDER: backup_storage_provider.provider
    })

    environment_variables = environment_variables.merge(backup_storage_provider.environment_variables).stringify_keys

    # Add the service into the backup directory
    if backup_storage_provider.provider.to_sym == :local
      environment_variables['DIRECTORY'] = environment_variables['DIRECTORY'] + "/#{backup.service.image.parameterize}-#{backup.service.id}"
    end

    docker_env_vars = environment_variables.map {|key, value| "#{key}=#{value}" }
    Rails.logger.info(docker_env_vars)

    backup_container_params = { 'Env' => docker_env_vars, 'Tty' => true }
    backup_container_params['HostConfig'] = {
      'Binds' => ["#{environment_variables['DIRECTORY']}:/backups"],
    } if backup_storage_provider.provider.to_sym == :local

    Rails.logger.info(backup_container_params)

    Rails.logger.info("sh #{backup.service.backup_script_path}")
    container = image.run("sh #{backup.service.backup_script_path}", backup_container_params)
    response = container.wait(3600)
    Rails.logger.info(container.logs(stderr: true))
    Rails.logger.info(container.logs(stdout: true))

    if response['StatusCode'] == 0
      backup.update(file_name: file_name)
      backup.complete!
    else
      backup.failed!
    end
  rescue
    Rails.logger.info("failed")
    backup.failed!
    raise
  end
end
