class CreateAccessLogs < ActiveRecord::Migration[6.1]
  def change
    enable_extension "btree_gin"

    create_table :access_logs, id: false do |t|
      t.datetime :timestamp
      t.string :action
      t.string :api_version
      t.string :host
      t.string :method
      t.string :path
      t.string :route
      t.string :controller
      t.string :duration
      t.string :status
      t.string :ip
      t.string :source
      t.belongs_to :jwt_api_entreprise, foreign_key: true, type: :uuid, index: true
      t.jsonb :params, default: '{}'
    end

    add_index :access_logs, "(params->>'siren')", using: :gin, name: 'index_access_logs_on_params_siren'
    add_index :access_logs, "(params->>'siret')", using: :gin, name: 'index_access_logs_on_params_siret'
    add_index :access_logs, "(params->>'siret_or_eori')", using: :gin, name: 'index_access_logs_on_params_siret_or_eori'
    add_index :access_logs, "(params->>'recipient')", using: :gin, name: 'index_access_logs_on_params_recipient'
  end
end
