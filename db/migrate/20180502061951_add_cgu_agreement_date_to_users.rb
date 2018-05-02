class AddCguAgreementDateToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :cgu_agreement_date, :timestamp
  end
end
