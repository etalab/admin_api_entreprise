class CreateTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :tokens do |t|
      t.string :value
      t.belongs_to :user, foreign_key: true, index: true

      t.timestamps
    end
  end
end
