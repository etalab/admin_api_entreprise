class User
  class Create < Trailblazer::Operation
    step Model(User, :new)
    step self::Contract::Build(constant: User::Contract::Create)
    step self::Contract::Validate()
    step self::Contract::Persist(method: :sync)
    step :lowercase_email
    step :generate_confirmation_token
    step :save_user

    def lowercase_email(model:, **)
      model.email = model.email.downcase
    end

    def generate_confirmation_token(model:, **)
      model.confirmation_token = SecureRandom.hex(10)
    end

    def save_user(model:, **)
      model.save
    end
  end
end
