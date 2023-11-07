module AuthorizationRequestsManagement
  extend ActiveSupport::Concern

  def show
    @authorization_request = extract_authorization_request
    @main_token = @authorization_request.token.decorate
    @banned_tokens = @authorization_request.tokens.blacklisted_later.decorate

    render 'shared/authorization_requests/show'
  rescue ActiveRecord::RecordNotFound
    error_message(title: t('.error.title'))

    redirect_current_user_to_homepage
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
