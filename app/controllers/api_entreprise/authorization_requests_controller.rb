# frozen_string_literal: true

class APIEntreprise::AuthorizationRequestsController < APIEntreprise::AuthenticatedUsersController
  def index
    @authorization_requests = current_user
      .authorization_requests
      .authorization_requests_for('entreprise')
      .submitted_at_least_once
      .order(
        first_submitted_at: :desc
      )
  end
end
