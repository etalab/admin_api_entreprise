# frozen_string_literal: true

module JwtAPIEntreprise::Operation
  class AccessRequestSatisfactionSurvey < ::Trailblazer::Operation
    step :fetch_eligible_tokens
    step :deliver_satisfaction_surveys

    def fetch_eligible_tokens(ctx, **)
      ctx[:tokens] = ::JwtAPIEntreprise.includes(:user).access_request_survey_not_sent.issued_in_last_seven_days.not_blacklisted
      ctx[:tokens].exists?
    end

    def deliver_satisfaction_surveys(_ctx, tokens:, **)
      tokens.find_each do |token|
        ::JwtAPIEntrepriseMailer.satisfaction_survey(token).deliver_later
        token.mark_access_request_survey_sent!
      end
      true
    end
  end
end
