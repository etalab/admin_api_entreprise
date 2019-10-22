module JwtApiEntreprise::Operation
  class AdminCreate < Trailblazer::Operation
    step self::Contract::Validate(constant: JwtApiEntreprise::Contract::AdminCreate)
    step :verify_user
    fail :error_message
    step :create_token
    step ->(_options, created_token:, **) { UserMailer.token_creation_notice(created_token).deliver_later }

    def verify_user(options, params:, **)
      options[:user] = User.find_by_id(params[:user_id])
    end

    # TODO: move this into a postgresql transaction
    def create_token(options, params:, user:, **)
      new_token = create_new_token_from params
      new_token.roles << Role.where(code: params[:roles])
      user.jwt_api_entreprise << new_token
      options[:created_token] = new_token.reload
    end

    def error_message(options, **)
      options[:errors] = "user does not exist (UID : '#{options[:params][:user_id]}')"
    end

    private

    def create_new_token_from(params)
      JwtApiEntreprise.create(
        subject: params[:subject],
        iat:     Time.zone.now.to_i,
        version: '1.0',
        exp:     18.months.from_now.to_i
      )
    end
  end
end
