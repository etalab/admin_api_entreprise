class CreateEditors < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    create_table :editors, id: :uuid do |t|
      t.string :name, null: false
      t.string :form_uids, array: true, default: []

      t.timestamps
    end

    add_column :users, :editor_id, :uuid
    add_index :users, :editor_id, algorithm: :concurrently
  end
end
