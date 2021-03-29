# frozen_string_literal: true

module JwtApiEntreprise::Operation
  class AccessRequestSatisfactionSurvey < ::Trailblazer::Operation
    step :fetch_eligible_tokens
    step :deliver_satisfaction_surveys

    def fetch_eligible_tokens(ctx, **)
      ctx[:tokens] = ::JwtApiEntreprise.seven_days_ago_created_tokens
                                       .includes(:user)
                                       .order_by_creation_datetime
    end

    def deliver_satisfaction_surveys(ctx, tokens:, **)
      tokens.find_each do |token|
        ::JwtApiEntrepriseMailer.satisfaction_survey(token.user.email, token.authorization_request_id).deliver_later
      end
    end
  end
end
