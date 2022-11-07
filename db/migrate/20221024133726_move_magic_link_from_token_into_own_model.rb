class MoveMagicLinkFromTokenIntoOwnModel < ActiveRecord::Migration[7.0]
  def up
    create_table :magic_links, id: :uuid do |t|
      t.string    :email,         null: false
      t.string    :access_token,  null: false
      t.timestamp :expires_at,    null: false

      t.timestamps
    end

    add_reference :magic_links, :token, foreign_key: true, type: :uuid, index: true
    add_index :magic_links, :access_token, unique: true

    Token.active.unexpired.where.not(magic_link_token: nil).each do |token|
      MagicLink.create(
        email: token.user.email,
        access_token: token.magic_link_token,
        created_at: token.magic_link_issuance_date
      )
    end

    remove_column :tokens, :magic_link_token, :string
    remove_column :tokens, :magic_link_issuance_date, :datetime
  end

  def down
    add_column :tokens, :magic_link_token, :string
    add_column :tokens, :magic_link_issuance_date, :datetime

    drop_table :magic_links
  end
end
