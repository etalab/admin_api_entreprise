class AddExpToJwtApiEntreprise < ActiveRecord::Migration[5.1]
  def change
    add_column :jwt_api_entreprises, :exp, :integer
  end
end
