class AccessRequestSatisfactionSurveyJob < ApplicationJob
  queue_as :default

  def perform(*args)
    JwtApiEntreprise::Operation::AccessRequestSatisfactionSurvey.call
  end
end
