module User::Contract
  AskPasswordRenewal = Dry::Validation.Schema do
    configure do
      config.messages_file = Rails.root
        .join('config/dry_validation_errors.yml').to_s

      def email_exists?(email)
        User.find_by(email: email)
      end
    end

    required(:email).filled(:str?, :email_exists?)
  end
end
