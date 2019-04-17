class JwtApiEntreprise
  class AdminCreate < Trailblazer::Operation
    step self::Contract::Validate(constant: JwtApiEntreprise::Contract::AdminCreate)
    step :verify_user
    failure :error_message
    step :create_token
    step ->(options, created_token:, **) { UserMailer.token_creation_notice(created_token).deliver_now }

    def verify_user(options, params:, **)
      options[:user] = User.find_by_id(params[:user_id])
    end

    # TODO move this into a postgresql transaction
    def create_token(options, params:, user:, **)
      new_token = JwtApiEntreprise.create({
        subject: params[:subject],
        iat: Time.now.to_i,
        version: '1.0',
        exp: 18.months.from_now.to_i
      })
      new_token.roles << Role.where(code: params[:roles])
      user.jwt_api_entreprise << new_token
      options[:created_token] = new_token.reload
    end

    def error_message(options, **)
      options[:errors] = "user does not exist (UID : '#{options[:params][:user_id]}')"
    end
  end
end
