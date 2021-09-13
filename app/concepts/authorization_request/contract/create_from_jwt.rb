module AuthorizationRequest::Contract
  class CreateFromJwt < Reform::Form
    property :user_id
    property :external_id

    validation do
      configure do
        config.messages_file = Rails.root
          .join('config/dry_validation_errors.yml').to_s

        def user_exists?(uid)
          User.exists?(uid)
        end
      end

      required(:user_id).filled(:str?, :user_exists?)
      required(:external_id).filled(:str?)

      # TODO Add a high level validation rule here to ensure at least one
      # business and one tech contact is provided in the payload
      required(:contacts).filled
    end

    collection :contacts,
      form: Contact::Contract::Upsert,
      populate_if_empty: Contact
  end
end
