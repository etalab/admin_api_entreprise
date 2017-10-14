class AddCodeToRoles < ActiveRecord::Migration[5.1]
  def change
    add_column :roles, :code, :string
  end
end
