class APIController < ActionController::API
  private

  def unauthorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
