class CreateJwtApiEntreprises < ActiveRecord::Migration[5.1]
  def change
    create_table :jwt_api_entreprises, id: :uuid do |t|
      t.string :subject
      t.integer :iat
      t.belongs_to :user, foreign_key: true, type: :uuid, index: true

      t.timestamps
    end
  end
end
