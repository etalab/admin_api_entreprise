module AuthenticationHelper
  ADMIN_PWD = 'coucou'

  def fill_request_headers_with_user_jwt(user_id)
    user_token = JWTF.generate(resource_owner_id: user_id)
    request.headers['Authorization'] = "Bearer #{user_token}"
  end

  def fill_request_headers_with_admin_jwt
    admin_user = create(:user, :admin)
    admin_token = JWTF.generate(resource_owner_id: admin_user.id)
    request.headers['Authorization'] = "Bearer #{admin_token}"
  end
end


