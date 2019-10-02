class AddEmptyStringDefaultToUserNote < ActiveRecord::Migration[6.0]
  def up
    change_column :users, :note, :text, default: ''

    apply_query = "update users set note = '' where note is null;"
    ActiveRecord::Base.connection.execute(apply_query)
  end

  def down
    change_column :users, :note, :text, default: nil
  end
end
