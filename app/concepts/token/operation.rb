class Token
  class Create < Trailblazer::Operation
    extend Contract::DSL

    contract 'params', (Dry::Validation.Schema do
      required(:token_payload) { filled? { each { str? } } }
    end)

    step Contract::Validate(name: 'params')
    # TODO verify user with dry-validation schema
    step :verify_user
    failure :error_message
    step :create_token

    def verify_user(options, params:, **)
      options[:user] = User.find_by_id(params[:user_id])
    end

    def create_token(options, params:, user:, **)
      new_token = AccessToken.create(params[:token_payload])
      options['created_token'] = user.tokens.create(value: new_token)
    end

    def error_message(options)
      options['manual_errors'] = 'user must exists'
    end
  end
end
