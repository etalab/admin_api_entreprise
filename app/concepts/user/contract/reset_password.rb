module User::Contract
  ResetPassword = Dry::Validation.Schema(PasswordParams) do
    configure do
      config.messages_file = Rails.root
        .join('config/dry_validation_errors.yml').to_s

      def pwd_token_exists?(token)
        User.find_by(pwd_renewal_token: token)
      end
    end

    required(:token).filled(:str?, :pwd_token_exists?)
  end
end
