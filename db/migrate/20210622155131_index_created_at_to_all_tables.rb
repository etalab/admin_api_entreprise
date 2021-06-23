class IndexCreatedAtToAllTables < ActiveRecord::Migration[6.1]
  def change
    add_index(:contacts, :created_at)
    add_index(:incidents, :created_at)
    add_index(:roles, :created_at)
    add_index(:users, :created_at)
  end
end
