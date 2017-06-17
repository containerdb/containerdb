class BackupAllWorker
  include Sidekiq::Worker

  def perform
    Service.where.not(backup_storage_provider: nil).each(&:backup)
  end
end
