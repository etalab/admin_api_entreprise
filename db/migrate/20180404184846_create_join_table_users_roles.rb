class CreateJoinTableUsersRoles < ActiveRecord::Migration[5.1]
  def change
    create_join_table :users, :roles, column_options: { type: :uuid } do |t|; end
  end
end
