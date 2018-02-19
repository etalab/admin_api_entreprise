class DeleteToken < ActiveRecord::Migration[5.1]
  def change
    drop_table :tokens
  end
end
