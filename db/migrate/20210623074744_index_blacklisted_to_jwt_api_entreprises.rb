class IndexBlacklistedToJwtAPIEntreprises < ActiveRecord::Migration[6.1]
  def change
    add_index(:jwt_api_entreprises, :blacklisted)
  end
end
