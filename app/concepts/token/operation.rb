class Token
  class Create < Trailblazer::Operation
    step :verify_user
    step :create_token

    def verify_user(options, user_id:, **)
      options[:user] = User.find_by_id(user_id)
    end

    def create_token(options, params:, user:, **)
      new_token = AccessToken.create(params[:token_payload])
      options[:created_token] = user.tokens.create(value: new_token)
    end
  end
end
