class BackupJob < ApplicationJob

  def perform(backup)
    backup.running!
    file_name = backup.service.backup_file_name
    environment_variables = backup.service.backup_environment_variables.merge({
      AWS_ACCESS_TOKEN: ENV['AWS_ACCESS_TOKEN'],
      AWS_SECRET_KEY: ENV['AWS_SECRET_KEY'],
      AWS_BUCKET_NAME: ENV['AWS_BUCKET_NAME'],
      FILE_NAME: file_name
    })

    image = Docker::Image.get('containerdb/backup-restore')
    container = image.run("sh #{backup.service.backup_script_path}", { 'Env' => environment_variables.map {|key, value| "#{key}=#{value}" } })

    # @todo capture Docker::Error::TimeoutError
    response = container.wait(3600)

    if response['StatusCode'] == 0
      backup.update(file_name: file_name)
      backup.complete!
    else
      backup.failed!
    end
  rescue
    backup.failed!
    raise
  end
end
