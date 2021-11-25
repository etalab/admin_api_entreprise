class DatapassWebhook::FindOrCreateUser < ApplicationInteractor
  def call
    context.user = User.find_or_initialize_by(email: user_attributes['email'].downcase)
    context.user.assign_attributes(user_attributes_to_assign)

    return if context.user.save

    fail!('User not valid', 'error', context.user.errors.to_h)
  end

  private

  def user_attributes_to_assign
    {
      'first_name' => user_attributes['given_name'],
      'last_name' => user_attributes['family_name'],
      'oauth_api_gouv_id' => user_attributes['uid']
    }
  end

  def user_attributes
    context.data['pass']['team_members'].find do |team_member|
      team_member['type'] == 'demandeur'
    end
  end
end
