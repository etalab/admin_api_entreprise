class DeleteAdminFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :admin, :boolean, default: false
  end
end
