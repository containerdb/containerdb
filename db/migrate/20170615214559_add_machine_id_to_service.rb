class AddMachineIdToService < ActiveRecord::Migration[5.1]
  def change
    add_column :services, :machine_id, :integer
  end
end
