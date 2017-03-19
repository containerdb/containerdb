class CreateServices < ActiveRecord::Migration[5.0]
  def change
    create_table :services do |t|
      t.string :image
      t.string :container_id
      t.string :password
      t.integer :port

      t.timestamps
    end
  end
end
