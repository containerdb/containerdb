class BackupJob < ApplicationJob

  def perform(backup)
    Rails.logger.info("Starting backup for #{backup.service.id}")
    unless backup.service.backup_storage_provider.present?
      backup.failed!
      return false
    end

    backup.running!
    file_name = backup.service.backup_file_name
    environment_variables = backup.service.backup_environment_variables.merge({
      AWS_ACCESS_TOKEN: backup.backup_storage_provider.environment_variables['AWS_ACCESS_TOKEN'],
      AWS_SECRET_KEY: backup.backup_storage_provider.environment_variables['AWS_SECRET_KEY'],
      AWS_BUCKET_NAME: backup.backup_storage_provider.environment_variables['AWS_BUCKET_NAME'],
      FILE_NAME: file_name
    })

    image = Docker::Image.get('containerdb/backup-restore')
    container = image.run("sh #{backup.service.backup_script_path}", { 'Env' => environment_variables.map {|key, value| "#{key}=#{value}" } })

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
