class User::ProconnectLogin < ApplicationInteractor
  def call
    context.user = User.find_or_initialize_by_email(user_email)
    context.user.assign_attributes(
      user_create_params
    )
    context.user.save
  end

  private

  def user_create_params
    {
      email: user_params['email'],
      last_name: user_params['last_name'],
      first_name: user_params['first_name'],
      oauth_api_gouv_id: user_params['uid']
    }
  end

  def user_params
    context.user_params || {}
  end

  def user_email
    user_params['email']
  end
end
