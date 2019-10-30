module User::Contract
  Confirm = Dry::Validation.Schema do
    configure do
      config.messages_file = Rails.root
        .join('config/dry_validation_errors.yml').to_s
      config.namespace = 'password'

      def confirmation_token_exists?(value)
        User.find_by(confirmation_token: value)
      end

      def confirmation_token_used?(value)
        !User.find_by(confirmation_token: value)&.confirmed?
      end
    end

    required(:confirmation_token).filled(
      :confirmation_token_exists?,
      :confirmation_token_used?
    )

    required(:password).filled(
      min_size?: 8,
      format?: /(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}/
    ).confirmation
    required(:cgu_checked).value(eql?: true)
  end
end
