module JwtApiEntreprise::Operation
  # TODO create an operation or activity for JWT creation to be called from admin or user request
  # ie remove token creation duplication
  class UserCreate < Trailblazer::Operation
    step self::Contract::Validate(constant: JwtApiEntreprise::Contract::UserCreate)
    step ->(options, params:, **) { options[:user] = User.find_by(id: params[:user_id]) }
    fail ->(options, params:, **) { options[:errors] = "user does not exist (UID : '#{params[:user_id]}')" }, fail_fast: true

    step :filter_authorized_roles
    fail ->(options, params:, **) { options[:errors] = 'No authorized roles given' }

    step :create_contact
    step :create_token
    step ->(options, created_token:, **) { UserMailer.token_creation_notice(created_token).deliver_later }

    def filter_authorized_roles(options, user:, params:, **)
      options[:authorized_roles] = user.roles.where(code: params[:roles])
      !options[:authorized_roles].empty?
    end

    def create_token(options, token_contact:, authorized_roles:, user:, params:, **)
      new_token = JwtApiEntreprise.create({
        subject: params[:subject],
        iat: Time.zone.now.to_i,
        version: '1.0',
        exp: 18.months.from_now.to_i
      })
      new_token.roles << authorized_roles
      new_token.contact = token_contact
      user.jwt_api_entreprise << new_token
      options[:created_token] = new_token.reload
    end

    def create_contact(options, user:, params:, **)
      token_contact = Contact.create({
        email: params[:contact][:email],
        phone_number: params[:contact][:phone_number],
        contact_type: 'token',
        user_id: user.id
      })
      options[:token_contact] = token_contact
    end
  end
end
