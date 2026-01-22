class CreateOAuthApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :oauth_applications, id: :uuid, default: -> { 'gen_random_uuid()' } do |t|
      t.string :name, null: false
      t.string :uid, null: false
      t.string :secret, null: false
      t.string :scopes, default: '', null: false
      t.string :owner_type
      t.uuid :owner_id

      t.timestamps
    end

    add_index :oauth_applications, :uid, unique: true
    add_index :oauth_applications, %i[owner_type owner_id]
  end
end
