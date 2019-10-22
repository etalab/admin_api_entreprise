module User::Contract
  Confirm = Dry::Validation.Schema do
    configure do
      config.messages_file = Rails.root
        .join('config/dry_validation_errors.yml').to_s
      config.namespace = 'password'
    end

    required(:confirmation_token).filled
    required(:password).filled(
      min_size?: 8,
      format?:   /(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}/
    ).confirmation
    required(:cgu_checked).value(eql?: true)
  end
end
