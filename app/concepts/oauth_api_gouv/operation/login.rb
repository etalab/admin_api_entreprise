module OAuthApiGouv::Operation
  class Login < Trailblazer::Operation
    step self::Contract::Validate(constant: OAuthApiGouv::Contract::Login),
      Output(:failure) => End(:invalid_params)
    step ->(ctx, params:, **) { ctx[:authorization_code] = params[:authorization_code] }
    step Subprocess(OAuthApiGouv::Tasks::RetrieveAccessToken),
      Output(:invalid_authorization_code) => End(:invalid_authorization_code)
    step Subprocess(OAuthApiGouv::Tasks::RetrieveUserInfo),
      Output(:unknown_user) => End(:unknown_user)
    step :generate_token_for_dashboard_access


    # Generate a JWT the way Doorkeeper does it
    # TODO Refactor when removing Doorkeeper dependency
    def generate_token_for_dashboard_access(ctx, user:, **)
      ctx[:dashboard_token] = JWTF.generate(resource_owner_id: user.id)
    end
  end
end
