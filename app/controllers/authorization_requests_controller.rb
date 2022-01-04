# frozen_string_literal: true

class AuthorizationRequestsController < AuthenticatedUsersController
  def index
    @authorization_requests = current_user
      .authorization_requests
      .submitted_at_least_once
      .order(
        first_submitted_at: :desc,
      )
  end
end
