class CreateNewUsersTable < ActiveRecord::Migration[5.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email
      t.string :context
      t.string :user_type

      t.timestamps
    end
  end
end
