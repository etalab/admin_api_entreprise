class AddPwdRenewalTokenSentAtToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :pwd_renewal_token_sent_at, :datetime
    add_index :users, :pwd_renewal_token
  end
end
