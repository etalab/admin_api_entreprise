class AddConstraintOnEmailAndContactTypeToContacts < ActiveRecord::Migration[6.1]
  def change
    change_column_null :contacts, :email, false
    change_column_null :contacts, :contact_type, false
  end
end
