# frozen_string_literal: true

class APIEntreprise::AuthorizationRequestsController < APIEntreprise::AuthenticatedUsersController
  include AuthorizationRequestsManagement

  def index
    @authorization_requests = current_user
      .authorization_requests
      .where(
        api: 'entreprise'
      )
      .submitted_at_least_once
      .order(
        first_submitted_at: :desc
      )
  end
end
