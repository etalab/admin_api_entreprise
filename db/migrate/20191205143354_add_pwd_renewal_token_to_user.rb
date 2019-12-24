class AddPwdRenewalTokenToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :pwd_renewal_token, :string, default: nil
  end
end
