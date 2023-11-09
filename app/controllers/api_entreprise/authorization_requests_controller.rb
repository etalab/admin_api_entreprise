# frozen_string_literal: true

class APIEntreprise::AuthorizationRequestsController < APIEntreprise::AuthenticatedUsersController
  include AuthorizationRequestsManagement

  layout :resolve_layout

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

  private

  def resolve_layout
    case action_name
    when 'index'
      'api_entreprise/authenticated_user'
    else
      'api_entreprise/application'
    end
  end
end
