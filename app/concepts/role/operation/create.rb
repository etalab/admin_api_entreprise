class Role
  class Create < Trailblazer::Operation
    extend Contract::DSL

    contract 'params', (Dry::Validation.Schema do
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
    end)

    step Model(Role, :new)
    step Contract::Validate(name: 'params')
    step :persist

    def persist(options, model:, params:, **)
      model.name = params[:name]
      model.code = params[:code]
      model.save!
    end
  end
end
