class AddIsAccessRequestSurveySentToJwtApiEntreprises < ActiveRecord::Migration[6.1]
  def change
    add_column :jwt_api_entreprises, :is_access_request_survey_sent, :boolean, default: false, null: false
    add_index :jwt_api_entreprises, :is_access_request_survey_sent
  end
end
