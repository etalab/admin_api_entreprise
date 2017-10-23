class CreateContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :contacts do |t|
      t.string :email
      t.string :phone_number
      t.string :contact_type

      t.timestamps
    end
  end
end
