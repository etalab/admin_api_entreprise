class User::UpdateOAuthAPIGouvId < ApplicationInteractor
  def call
    context.user.update(oauth_api_gouv_id: context.oauth_api_gouv_id)
  end
end
