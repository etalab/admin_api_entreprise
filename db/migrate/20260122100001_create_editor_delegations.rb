class CreateEditorDelegations < ActiveRecord::Migration[8.1]
  def change
    create_table :editor_delegations, id: :uuid, default: -> { 'gen_random_uuid()' } do |t|
      t.references :editor, null: false, foreign_key: true, type: :uuid
      t.references :authorization_request, null: false, foreign_key: true, type: :uuid
      t.datetime :revoked_at

      t.timestamps
    end

    add_index :editor_delegations, %i[editor_id authorization_request_id],
      unique: true,
      where: 'revoked_at IS NULL',
      name: 'index_active_editor_delegations_unique'
  end
end
