class CreateRoles < ActiveRecord::Migration[5.1]
  def change
    enable_extension "pgcrypto"
    create_table :roles, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
  end
end
