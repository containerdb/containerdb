class AddHostnameAndDataDirectoryToMachine < ActiveRecord::Migration[5.1]
  def change
    add_column :machines, :hostname, :string
    add_column :machines, :data_directory, :string
  end
end
