class AddBackupStorageProviderIdToServices < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :backup_storage_provider_id, :integer
  end
end
