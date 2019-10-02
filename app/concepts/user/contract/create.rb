module User::Contract
  class Create < Reform::Form
    property :email
    property :context
    property :note

    validation do
      configure do
        config.messages_file = Rails.root
          .join('config/dry_validation_errors.yml').to_s

        def unique?(value)
          existing_email = User.find_by(email: value)
          !existing_email
        end
      end

      required(:email).filled(
        format?: /\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\z/,
        &:unique?
      )
      required(:context).maybe(:str?)
      required(:note).maybe(:str?)
    end
  end
end
