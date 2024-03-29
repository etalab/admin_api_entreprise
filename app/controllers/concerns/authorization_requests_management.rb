module AuthorizationRequestsManagement
  extend ActiveSupport::Concern

  def show
    @authorization_request = extract_authorization_request
    @main_token = @authorization_request.token.decorate
    @inactive_tokens = @authorization_request.tokens.inactive.order(exp: :desc)
    @access_logs_counts = AccessLogsCounts.new(@inactive_tokens)
    @banned_tokens = @authorization_request.tokens.blacklisted_later.decorate

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
