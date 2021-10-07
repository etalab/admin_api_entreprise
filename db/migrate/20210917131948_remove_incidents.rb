class RemoveIncidents < ActiveRecord::Migration[6.1]
  unless Kernel.const_defined?("Incident")
    class Incident < ApplicationRecord; end
  end

  def up
    drop_table "incidents"
  end

  def down
    create_table "incidents", id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string "title"
      t.string "subtitle"
      t.text "description"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["created_at"], name: "index_incidents_on_created_at"
    end
  end
end
