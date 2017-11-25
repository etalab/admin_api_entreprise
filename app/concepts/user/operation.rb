class User
  class Create < Trailblazer::Operation
    step Model(User, :new)
    step :skip_auto_confirmation_email
    step self::Contract::Build(constant: User::Contract::Create)
    step self::Contract::Validate()
    step self::Contract::Persist()

    # Don't let Devise automaticaly send confirmation email on user creation
    def skip_auto_confirmation_email(options, model:, **)
      # model.skip_confirmation!
      model.skip_confirmation_notification!
    end
  end
end
