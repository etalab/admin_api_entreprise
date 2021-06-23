class IndexArchivedToJwtApiEntreprises < ActiveRecord::Migration[6.1]
  def change
    add_index(:jwt_api_entreprises, :archived)
  end
end
