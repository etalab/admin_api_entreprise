module User::Operation
  class Login < Trailblazer::Operation
    step :retrieve_user_from_email
    step ->(options, model:, **) { model.confirmed? }
    step :authenticate_user

    def retrieve_user_from_email(options, params:, **)
      # Oauth2 spec uses 'username' as key
      strip_email = params[:username].strip
      options[:model] = User.find_by(email: strip_email)
    end

    def authenticate_user(options, model:, params:, **)
      model.authenticate(params[:password])
    end
  end
end
