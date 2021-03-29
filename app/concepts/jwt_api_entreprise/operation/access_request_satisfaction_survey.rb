# frozen_string_literal: true

module JwtApiEntreprise::Operation
  class AccessRequestSatisfactionSurvey < ::Trailblazer::Operation
    step :fetch_eligible_tokens
    step :deliver_satisfaction_surveys

    def fetch_eligible_tokens(ctx, **)
      ctx[:tokens] = ::JwtApiEntreprise.satisfaction_survey_eligible_tokens
    end

    def deliver_satisfaction_surveys(_ctx, tokens:, **)
      tokens.find_each do |token|
        ::JwtApiEntrepriseMailer.satisfaction_survey(token.id, token.user.email, token.authorization_request_id).deliver_later
      end
    end
  end
end
