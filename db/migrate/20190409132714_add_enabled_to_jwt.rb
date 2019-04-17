class AddEnabledToJwt < ActiveRecord::Migration[5.1]
  def change
    add_column :jwt_api_entreprises, :enabled, :boolean, default: true
  end
end
