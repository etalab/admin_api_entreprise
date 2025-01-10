class AddCanCopyTokenToEditors < ActiveRecord::Migration[8.0]
  def change
    add_column :editors, :copy_token, :boolean, default: false, null: false
  end
end
