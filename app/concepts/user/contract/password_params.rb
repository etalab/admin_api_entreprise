module User::Contract
  PasswordParams = Dry::Validation.Schema do
    required(:password).filled(
      min_size?: 8,
      format?: /(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}/
    ).confirmation
  end
end
