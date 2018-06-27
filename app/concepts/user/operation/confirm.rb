class User
  class Confirm < Trailblazer::Operation
    step self::Contract::Validate(constant: User::Contract::Confirm)
    step :retrieve_user_from_token
    failure :invalid_token, fail_fast: true
    step ->(options, model:, **) { model.cgu_agreement_date = Time.now }
    step ->(options, model:, **) { model.confirm }
    failure :user_already_confirmed
    step :set_user_password
    step :dispose_session_token

    def retrieve_user_from_token(options, params:, **)
      options[:model] = User.find_by(
        confirmation_token: params[:confirmation_token]
      )
    end

    def set_user_password(options, model:, params:, **)
      model.update_attribute :password, params[:password]
    end

    def dispose_session_token(options, model:, **)
      # Call JWTF the way Doorkeeper does it
      jwt = JWTF.generate(resource_owner_id: model.id)
      options['access_token'] = jwt
    end

    # TODO Set errors field into higher level application operation
    # as a generic way of handling business errors
    def invalid_token(options, **)
      options['errors'] = [] if options['errors'].nil?
      options['errors'] << 'invalid token'
    end

    def user_already_confirmed(options, **)
      options['errors'] = [] if options['errors'].nil?
      options['errors'] << 'user already confirmed'
    end
  end
end
