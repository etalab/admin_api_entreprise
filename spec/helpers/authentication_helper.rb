module AuthenticationHelper
  ADMIN_UID = Rails.application.secrets.fetch(:admin_uid)

  def fill_request_headers_with_user_jwt(user_id)
    user_token = JWTF.generate(resource_owner_id: user_id)
    request.headers['Authorization'] = "Bearer #{user_token}"
  end

  def fill_request_headers_with_admin_jwt
    create(:admin)
    admin_token = JWTF.generate(resource_owner_id: ADMIN_UID)
    request.headers['Authorization'] = "Bearer #{admin_token}"
  end
end
