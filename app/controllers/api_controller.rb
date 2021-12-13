class APIController < ActionController::API
  private

  def unauthorized
    render json: { error: 'Unauthorized' }, status: 401
  end
end
