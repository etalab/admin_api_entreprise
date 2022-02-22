class User
  class FindFromEmail < ApplicationInteractor
    def call
      context.user = User.insensitive_find_by_email(api_gouv_email)
      fail!('not_found', 'warn') unless context.user
    end

    private

    def api_gouv_email
      context.oauth_api_gouv_email
    end
  end
end
