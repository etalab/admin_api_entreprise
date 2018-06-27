class Role
  module Contract
    Create = Dry::Validation.Schema do
      configure do
        config.messages_file = Rails.root
          .join('config/dry_validation_errors.yml').to_s

        def unique?(attr_name, value)
          Role.where(attr_name => value).empty?
        end
      end

      required(:name).filled(:str?, max_size?: 50, unique?: :name)
      # required(:code).filled(:str?, max_size?: 4)
      required(:code).filled(:str?, unique?: :code)
    end
  end
end
