class RenameEnabledToBlacklisted < ActiveRecord::Migration[5.2]
  def change
    rename_column :jwt_api_entreprises, :enabled, :blacklisted
    change_column :jwt_api_entreprises, :blacklisted, :boolean, default: false
  end
end
