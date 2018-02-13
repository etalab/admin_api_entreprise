class Token
  class Create < Trailblazer::Operation
    extend Contract::DSL

    contract 'params', (Dry::Validation.Schema do
      required(:roles) { filled? { each { str? } } }
      required(:user_id).filled(:str?)
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
      apie_payload = Hash.new.tap do |p|
        p[:uid] = user.id
        p[:roles] = params[:roles]
      end
      new_token = AccessToken.create(apie_payload)
      options['created_token'] = user.tokens.create(value: new_token)
    end

    def error_message(options)
      options['errors'] = "user does not exist (UID : '#{options['params'][:user_id]}')"
    end
  end
end
