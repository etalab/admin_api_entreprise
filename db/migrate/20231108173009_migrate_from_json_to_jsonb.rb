class MigrateFromJsonToJsonb < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      change_column :tokens, :days_left_notification_sent, :jsonb, default: [], using: 'days_left_notification_sent::jsonb'
      change_column :tokens, :extra_info, :jsonb, default: {}, using: 'extra_info::jsonb'
    end
  end
end
