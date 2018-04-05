class JwtApiEntreprise
  class UserCreate < Trailblazer::Operation
    extend Contract::DSL

    contract 'params', (Dry::Validation.Schema do
      required(:roles) { filled? { each { str? } } }
      required(:user_id).filled(:str?)
      required(:subject).filled(:str?)
    end)

    step Contract::Validate(name: 'params')
    step ->(options, params:, **) { options['user'] = User.find_by(id: params[:user_id]) }
    failure ->(options, params:, **) { options['errors'] = "user does not exist (UID : '#{params[:user_id]}')" }, fail_fast: true

    step :filter_authorized_roles
    failure ->(options, params:, **) { options['errors'] = 'No authorized roles given' }

    step :create_token

    def filter_authorized_roles(options, user:, params:, **)
      options['authorized_roles'] = user.roles.where(code: params[:roles])
      !options['authorized_roles'].empty?
    end

    def create_token(options, authorized_roles:, user:, params:, **)
      new_token = JwtApiEntreprise.create({
        subject: params[:subject],
        iat: Time.now.to_i
      })
      new_token.roles << authorized_roles
      user.jwt_api_entreprise << new_token
      options['created_token'] = new_token.reload
    end
  end
end
