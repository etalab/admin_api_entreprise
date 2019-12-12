module User::Operation
  class Create < Trailblazer::Operation
    step Model(User, :new)
    step self::Contract::Build(constant: User::Contract::Create)
    step self::Contract::Validate()
    step self::Contract::Persist(method: :sync)
    step ->(options, model:, **) { model.generate_confirmation_token }
    step ->(options, model:, **) { model.confirmation_sent_at = Time.zone.now }
    step ->(options, model:, **) { model.save }
    step ->(options, model:, **) { UserMailer.confirm_account_action(model).deliver_later }
  end
end
