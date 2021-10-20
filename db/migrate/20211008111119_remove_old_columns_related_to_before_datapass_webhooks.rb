class RemoveOldColumnsRelatedToBeforeDatapassWebhooks < ActiveRecord::Migration[6.1]
  def up
    remove_column :contacts, :jwt_api_entreprise_id
    remove_column :jwt_api_entreprises, :user_id
  end

  def down
    add_column :contacts, :jwt_api_entreprise_id, :uuid
    add_index :contacts, :jwt_api_entreprise_id
    add_foreign_key :contacts, :jwt_api_entreprises

    add_column :jwt_api_entreprises, :user_id, :uuid
    add_index :jwt_api_entreprises, :user_id
    add_foreign_key :jwt_api_entreprises, :users
  end
end
