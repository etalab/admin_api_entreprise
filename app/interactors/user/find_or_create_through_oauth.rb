class User
  class FindOrCreateThroughOAuth < ApplicationInteractor
    def call
      context.user = User.insensitive_find_by_email(api_gouv_email) || create_user
    end

    private

    def create_user
      User.create!(
        user_create_params
      )
    end

    def user_create_params
      {
        last_name: user_params['family_name'],
        first_name: user_params['given_name'],
        email: api_gouv_email
      }
    end

    def user_params
      context.oauth_api_gouv_info
    end

    def api_gouv_email
      context.oauth_api_gouv_email
    end
  end
end
