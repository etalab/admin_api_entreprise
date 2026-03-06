class AddDelegationsEnabledToEditors < ActiveRecord::Migration[8.0]
  def change
    add_column :editors, :delegations_enabled, :boolean, default: false, null: false
  end
end
