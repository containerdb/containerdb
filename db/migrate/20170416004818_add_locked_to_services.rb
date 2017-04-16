class AddLockedToServices < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :locked, :boolean, default: false
  end
end
