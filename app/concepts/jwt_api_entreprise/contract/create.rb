module JwtAPIEntreprise::Contract
  class Create < Reform::Form
    property :authorization_request
    property :authorization_request_id
    property :subject

    validation do
      configure do
        config.messages_file = Rails.root
          .join('config/dry_validation_errors.yml').to_s

        def user_exists?(uid)
          User.exists?(uid)
        end
      end

      required(:authorization_request)
      required(:authorization_request_id).filled(:str?)

      required(:subject).filled(:str?)

      # TODO Add a rule to validate the format of the :roles data to ensure
      # the populator won't fail (format should be [{ code: '...' }, { ... }])
      required(:roles).filled
    end

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
      Role.find_by_code(options[:fragment][:code]) || Role.new
    end
  end
end
