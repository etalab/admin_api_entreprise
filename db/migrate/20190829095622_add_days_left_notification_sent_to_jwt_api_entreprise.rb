class AddDaysLeftNotificationSentToJwtAPIEntreprise < ActiveRecord::Migration[5.2]
  def change
    add_column :jwt_api_entreprises, :days_left_notification_sent, :json, default: [], null: false
  end
end
