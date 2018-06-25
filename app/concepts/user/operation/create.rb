class User
  class Create < Trailblazer::Operation
    step Model(User, :new)
    step self::Contract::Build(constant: User::Contract::Create)
    step self::Contract::Validate()
    step self::Contract::Persist(method: :sync)
    step ->(options, model:, **) { model.email = model.email.downcase }
    step ->(options, model:, **) { model.generate_confirmation_token }
    step ->(options, model:, **) { model.confirmation_sent_at = Time.now }
    step ->(options, model:, **) { model.save }
    step ->(options, model:, **) { UserMailer.confirmation_request(model).deliver_now }
  end
end
