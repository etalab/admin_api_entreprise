class AddUserToContact < ActiveRecord::Migration[5.1]
  def change
    add_reference :contacts, :user, foreign_key: true, type: :uuid, index: true
  end
end
