class CreateJoinTableJwtApiEntreprisesRoles < ActiveRecord::Migration[5.1]
  def change
    create_join_table :jwt_api_entreprises, :roles, column_options: { type: :uuid } do |t|
      # t.index [:jwt_api_entreprise_id, :role_id]
      # t.index [:role_id, :jwt_api_entreprise_id]
    end
  end
end
