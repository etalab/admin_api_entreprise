class CreateEditorDelegations < ActiveRecord::Migration[8.0]
  def change
    create_table :editor_delegations, id: :uuid do |t|
      t.uuid :editor_id, null: false
      t.uuid :authorization_request_id, null: false
      t.datetime :revoked_at
      t.timestamps
    end

    add_index :editor_delegations, %i[editor_id authorization_request_id],
      unique: true, where: 'revoked_at IS NULL', name: 'idx_editor_delegations_editor_ar_active'
    add_foreign_key :editor_delegations, :editors, validate: false
    add_foreign_key :editor_delegations, :authorization_requests, validate: false
  end
end
