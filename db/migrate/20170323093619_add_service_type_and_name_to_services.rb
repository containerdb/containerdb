class AddServiceTypeAndNameToServices < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :service_type, :string
    add_column :services, :name, :string
  end
end
