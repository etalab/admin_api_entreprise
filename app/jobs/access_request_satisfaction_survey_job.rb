class AccessRequestSatisfactionSurveyJob < ApplicationJob
  queue_as :default

  def perform
    JwtAPIEntreprise::Operation::AccessRequestSatisfactionSurvey.call
  end
end
