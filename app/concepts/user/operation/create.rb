class User
  class Create < Trailblazer::Operation
    step Model(User, :new)
    step self::Contract::Build(constant: User::Contract::Create)
    step self::Contract::Validate()
    step self::Contract::Persist(method: :sync)
    step ->(model:, **) { model.email = model.email.downcase }
    step ->(model:, **) { model.generate_confirmation_token }
    step ->(model:, **) { model.confirmation_sent_at = Time.now }
    step ->(model:, **) { model.save }
    step ->(model:, **) { UserMailer.confirmation_request(model).deliver_now }
  end
end
