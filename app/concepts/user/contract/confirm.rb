class User
  class Contract
    def self.confirm
      Dry::Validation.Schema do
        configure do
          config.messages_file = Rails.root
            .join('config/dry_validation_errors.yml').to_s
          config.namespace = 'password'
        end

        required(:confirmation_token).filled
        required(:password).filled(
          min_size?: 8,
          format?: /(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}/
        ).confirmation
      end
    end
  end
end
