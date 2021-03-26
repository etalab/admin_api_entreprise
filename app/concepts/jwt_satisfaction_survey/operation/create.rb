# frozen_string_literal: true

module JwtSatisfactionSurvey::Operation
  class Create < ::Trailblazer::Operation
    step :deliver_satisfaction_surveys

    def deliver_satisfaction_surveys(_, **)
      tokens.find_each do |token|
        ::JwtApiEntrepriseMailer.satisfaction_survey(token.user.email, token.authorization_request_id).deliver_later
      end
    end

    private

    def tokens
      ::JwtApiEntreprise.seven_days_ago_created_tokens
                        .includes(:user)
                        .order_by_issued_time
    end
  end
end
