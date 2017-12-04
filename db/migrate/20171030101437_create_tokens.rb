class CreateTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :tokens, id: :uuid do |t|
      t.string :value
      t.belongs_to :user, foreign_key: true, type: :uuid, index: true

      t.timestamps
    end
  end
end
