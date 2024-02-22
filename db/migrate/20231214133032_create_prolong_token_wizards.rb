class CreateProlongTokenWizards < ActiveRecord::Migration[7.1]
  def change
    create_table :prolong_token_wizards, id: :uuid do |t|
      t.references :token, null: false, foreign_key: true, type: :uuid
      t.string :owner
      t.boolean :project_purpose
      t.boolean :contact_metier
      t.boolean :contact_technique
      t.integer :status

      t.timestamps
    end
  end
end
