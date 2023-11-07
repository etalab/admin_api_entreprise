class RemoveAccessRequestSurveySentToTokens < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      remove_column :tokens, :access_request_survey_sent, :boolean, default: false, null: false
    end
  end

  def down
    safety_assured do
      add_column :tokens, :access_request_survey_sent, :boolean, default: false, null: false
      add_index :tokens, :access_request_survey_sent
    end
  end
end
