class CreateEditorTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :editor_tokens, id: :uuid do |t|
      t.uuid :editor_id, null: false
      t.integer :iat
      t.integer :exp, null: false
      t.datetime :blacklisted_at
      t.timestamps
    end

    add_foreign_key :editor_tokens, :editors, validate: false
  end
end
