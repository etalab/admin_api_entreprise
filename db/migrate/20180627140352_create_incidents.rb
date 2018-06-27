class CreateIncidents < ActiveRecord::Migration[5.1]
  def change
    create_table :incidents, id: :uuid do |t|
      t.string :title
      t.string :subtitle
      t.text :description

      t.timestamps
    end
  end
end
