class CreateMachines < ActiveRecord::Migration[5.1]
  def change
    create_table :machines do |t|
      t.string :name
      t.string :docker_url

      t.timestamps
    end
  end
end
