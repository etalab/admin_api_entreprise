module AuthorizationRequestsManagement
  extend ActiveSupport::Concern

  def show
    @authorization_request = current_user
      .authorization_requests
      .where(api:)
      .viewable_by_users
      .find(params[:id])

    render 'shared/authorization_requests/show'
  rescue ActiveRecord::RecordNotFound
    error_message(title: t('.error.title'))
    
    redirect_current_user_to_homepage
  end

  private

  def api
    namespace.slice(4..-1)
  end
end
