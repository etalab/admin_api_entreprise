module User::Operation
  class Create < Trailblazer::Operation
    step Model(User, :new)
    step self::Contract::Build(constant: User::Contract::Create)
    step self::Contract::Validate()
    step self::Contract::Persist(method: :sync)
    step ->(_options, model:, **) { model.email = model.email.downcase }
    step ->(_options, model:, **) { model.generate_confirmation_token }
    step ->(_options, model:, **) { model.confirmation_sent_at = Time.zone.now }
    step ->(_options, model:, **) { model.save }
    step ->(_options, model:, **) { UserMailer.confirm_account_action(model).deliver_later }
    step :send_confirm_account_notice

    def send_confirm_account_notice(_ctx, model:, **)
      if model.contacts.any? && a_contact_has_distinct_email?(model)
        UserMailer.confirm_account_notice(model).deliver_later
      else
        true
      end
    end

    private

    def a_contact_has_distinct_email?(model)
      model.contacts.pluck(:email).any? { |email| email != model.email }
    end
  end
end
