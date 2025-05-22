class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations, id: :uuid do |t|
      t.string :siret, null: false, index: { unique: true }
      t.jsonb :insee_payload, default: {}
      t.datetime :last_insee_payload_updated_at

      t.timestamps
    end

    add_check_constraint :organizations,
                      "LENGTH(siret) = 14",
                      name: "siret_length_check"
  end
end
