class CreateAccessLogViews < ActiveRecord::Migration[7.0]
  def change
    create_view :access_logs_view
  end
end
