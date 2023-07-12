class RemoveUselessAttributesOnUsers < ActiveRecord::Migration[7.0]
  def up
    safety_assured do
      remove_column :users, :cgu_agreement_date, :datetime, precision: nil
      remove_column :users, :note, :string
      remove_column :users, :context, :string
      remove_column :users, :pwd_renewal_token, :string
      remove_column :users, :pwd_renewal_token_sent_at, :datetime, precision: nil
    end
  end

  def down
    add_column :users, :cgu_agreement_date, :datetime, precision: nil
    add_column :users, :note, :string
    add_column :users, :context, :string
    add_column :users, :pwd_renewal_token, :string
    add_column :users, :pwd_renewal_token_sent_at, :datetime, precision: nil

    add_index :users, :pwd_renewal_token
  end
end
