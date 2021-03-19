module User::Contract
  class Create < Reform::Form
    property :email
    property :oauth_api_gouv_id
    property :context
    property :note
    property :cgu_agreement_date
    property :first_name
    property :last_name

    validation do
      configure do
        config.messages_file = Rails.root
          .join('config/dry_validation_errors.yml').to_s

        def unique?(value)
          existing_email = User.find_by(email: value)
          !existing_email
        end

        def datetime?(value)
          Time.zone.parse(value)
        rescue ArgumentError
          false
        end
      end

      required(:email).filled(format?: ParamsValidation::EmailRegex, &:unique?)
      required(:context).maybe(:str?)
      required(:note).maybe(:str?)
      required(:cgu_agreement_date).filled(:datetime?)
      required(:oauth_api_gouv_id).filled(:str?)
    end
  end
end
