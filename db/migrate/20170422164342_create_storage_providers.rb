class CreateStorageProviders < ActiveRecord::Migration[5.0]
  def change
    create_table :storage_providers do |t|
      t.string :provider
      t.string :name
      t.hstore :environment_variables, default: {}

      t.timestamps
    end
  end
end
