class ApplicationController < ActionController::API
  include Pundit
  before_action :jwt_authenticate!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def jwt_authenticate!
    authent = Request::Operation::Authenticate.call(request: request)

    if authent.success?
      @pundit_user = authent[:authenticated_user]
    else
      unauthorized
    end
  end

  def unauthorized
    render(json: { error: 'Unauthorized' }, status: 401)
  end

  # Method called by Pundit to get the current user of the request
  # @pundit_user is the first argument passed to policies
  def pundit_user
    @pundit_user
  end

  def current_user
    @pundit_user
  end

  def user_not_authorized
    render(json: { errors: 'Forbidden' }, status: 403)
  end
end
