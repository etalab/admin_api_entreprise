class JwtSatisfactionSurveyJob < ApplicationJob
  queue_as :default

  def perform(*args)
    JwtSatisfactionSurvey::Operation::Create.call
  end
end
