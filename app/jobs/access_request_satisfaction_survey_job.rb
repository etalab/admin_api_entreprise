class AccessRequestSatisfactionSurveyJob < ApplicationJob
  queue_as :default

  def perform
    JwtApiEntreprise::Operation::AccessRequestSatisfactionSurvey.call
  end
end
