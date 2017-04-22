class AddHostedToServices < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :hosted, :boolean, default: true
  end
end
