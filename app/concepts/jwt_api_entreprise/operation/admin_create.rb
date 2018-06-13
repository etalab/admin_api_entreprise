class JwtApiEntreprise
  class AdminCreate < Trailblazer::Operation
    extend Contract::DSL

    contract 'params', (Dry::Validation.Schema do
      required(:roles) { filled? { each { str? } } }
      required(:user_id).filled(:str?)
      required(:subject).maybe(:str?)
    end)

    step Contract::Validate(name: 'params')
    step :verify_user
    failure :error_message
    step :create_token

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
      options['created_token'] = new_token.reload
    end

    def error_message(options)
      options['errors'] = "user does not exist (UID : '#{options['params'][:user_id]}')"
    end
  end
end
