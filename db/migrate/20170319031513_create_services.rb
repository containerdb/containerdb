class CreateServices < ActiveRecord::Migration[5.0]
  def change
    enable_extension "hstore"
    create_table :services do |t|
      t.string :type
      t.string :image
      t.string :container_id
      t.hstore :environment_variables
      t.integer :port

      t.timestamps
    end
  end
end
