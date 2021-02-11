class AddTokensNewlyTransferedToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :tokens_newly_transfered, :boolean, default: false
  end
end
