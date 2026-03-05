module AuthorizationRequestsManagement
  extend ActiveSupport::Concern

  def show
    @authorization_request = extract_authorization_request
    @main_token = @authorization_request.token.decorate
    @other_tokens = @authorization_request.tokens.where.not(id: @main_token.id).decorate
    load_delegations_data

    render 'shared/authorization_requests/show'
  rescue ActiveRecord::RecordNotFound
    error_message(title: t('.error.title'))

    redirect_current_user_to_homepage
  end

  def index
    @authorization_requests = current_user
      .authorization_requests
      .where(api:)
      .submitted_at_least_once
      .viewable_by_users
      .order(
        first_submitted_at: :desc
      ).includes(:active_token)

    render 'shared/authorization_requests/index'
  end

  private

  def load_delegations_data
    @active_delegations = @authorization_request.editor_delegations.active.includes(:editor)
    @available_editors = @authorization_request.available_editors_for_delegation
  end

  def extract_authorization_request
    current_user
      .authorization_requests
      .where(api:)
      .viewable_by_users
      .find(params[:id])
  end

  def api
    namespace.slice(4..-1)
  end
end
