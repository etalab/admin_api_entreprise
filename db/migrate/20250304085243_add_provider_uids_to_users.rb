class AddProviderUidsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :provider_uids, :string, array: true, default: [], null: false
  end
end
