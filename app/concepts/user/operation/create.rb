class User
  class Create < Trailblazer::Operation
    step Model(User, :new)
    step self::Contract::Build(constant: User::Contract::Create)
    step self::Contract::Validate()
    step self::Contract::Persist(method: :sync)
    step ->(model:, **) { model.email = model.email.downcase }
    step ->(model:, **) { model.generate_confirmation_token }
    step ->(model:, **) { model.save }
  end
end
