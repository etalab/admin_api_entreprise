class AddUserToContact < ActiveRecord::Migration[5.1]
  def change
    add_reference :contacts, :user, foreign_key: true, index: true
  end
end
