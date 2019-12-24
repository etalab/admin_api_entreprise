module User::Operation
  class ResetPassword < Trailblazer::Operation
    step self::Contract::Validate(constant: User::Contract::ResetPassword)
    fail :validation_errors, fail_fast: true
    step :retrieve_user_from_token
    step :renewal_token_valid?
    fail :log_renewal_token_expired
    step :reset_user_password
    step :put_back_session_token

    def validation_errors(ctx, **)
      ctx[:errors] = {} if ctx[:errors].nil?
      ctx[:errors].merge! ctx['result.contract.default'].errors
    end

    def retrieve_user_from_token(ctx, params:, **)
      ctx[:user] = User.find_by(pwd_renewal_token: params[:token])
    end

    def reset_user_password(ctx, user:, params:, **)
      user.update(
        password: params[:password],
        pwd_renewal_token: nil
      )
    end

    def put_back_session_token(ctx, user:, **)
      # Call JWTF the way Doorkeeper does it
      jwt = JWTF.generate(resource_owner_id: user.id)
      ctx[:access_token] = jwt
    end

    def renewal_token_valid?(ctx, user:, **)
      token_issued_at = user.pwd_renewal_token_sent_at
      token_issued_at > 24.hours.ago
    end

    def log_renewal_token_expired(ctx, **)
      ctx[:errors] = 'Le lien de renouvellement de mot de passe a expiré'
    end
  end
end
