class CreateBackups < ActiveRecord::Migration[5.0]
  def change
    create_table :backups do |t|
      t.integer :service_id
      t.string :file_name
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
