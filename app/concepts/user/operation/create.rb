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
    step ->(options, model:, **) { UserMailer.confirm_account_action(model).deliver_now }
    step :send_confirm_account_notice

    def send_confirm_account_notice(ctx, model:, **)
      if model.contacts.any?
        UserMailer.confirm_account_notice(model).deliver_now
      else
        true
      end
    end
  end
end
