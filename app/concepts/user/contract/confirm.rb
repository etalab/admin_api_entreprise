class User
  class Contract
    def self.confirm
      Dry::Validation.Schema do
        configure do
          config.messages_file = "#{Rails.root.join('config/dry_validation_errors.yml')}"
          config.namespace = 'password'
        end

        required(:confirmation_token).filled
        required(:password).filled(min_size?: 8, format?: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\z/)
          .confirmation
      end
    end
  end
end
