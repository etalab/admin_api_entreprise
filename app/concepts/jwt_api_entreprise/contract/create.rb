module JwtApiEntreprise::Contract
  class Create < Reform::Form
    property :user_id
    property :subject

    validation do
      configure do
        config.messages_file = Rails.root
          .join('config/dry_validation_errors.yml').to_s

        def user_exists?(uid)
          User.exists?(uid)
        end
      end

      required(:user_id).filled(:str?, :user_exists?)
      required(:subject).filled(:str?)

      # TODO Add a high level validation rule here to ensure at least one
      # business and one tech contact is provided in the payload
      required(:contacts).filled

      # TODO Add a rule to validate the format of the :roles data to ensure
      # the populator won't fail (format should be [{ code: '...' }, { ... }])
      required(:roles).filled
    end

    collection :contacts,
      form: Contact::Contract::Upsert,
      populate_if_empty: Contact

    collection :roles, populate_if_empty: :populate_roles_from_code do
      property :code

      validation with: { form: true } do
        configure do
          config.messages_file = Rails.root
            .join('config/dry_validation_errors.yml').to_s

          def role_exists?(code)
            form.model.persisted?
          end
        end

        required(:code).filled(:role_exists?)
      end
    end


    def populate_roles_from_code(options)
      Role.find_by_code(options[:fragment][:code]) or Role.new
    end
  end
end
