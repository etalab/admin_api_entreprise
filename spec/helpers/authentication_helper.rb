module AuthenticationHelper
  ADMIN_UID = 'bacb9bbc-f208-4b23-a176-67504d4920dd'

  def set_user_token(user_id)
    user_token = JWTF.generate(resource_owner_id: user_id)
    request.headers['Authorization'] = "Bearer #{user_token}"
  end

  def set_admin_token
    admin_token = JWTF.generate(resource_owner_id: ADMIN_UID)
    request.headers['Authorization'] = "Bearer #{admin_token}"
  end
end


