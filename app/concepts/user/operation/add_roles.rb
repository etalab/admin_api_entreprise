class User
  class AddRoles < Trailblazer::Operation
    extend self::Contract::DSL

    contract 'params', (Dry::Validation.Schema do
      required(:id).filled(:str?)
      required(:roles) { filled? { each { str? } } }
    end)

    step self::Contract::Validate(name: 'params')
    step ->(options, params:, **) { options['model'] = User.find_by(id: params[:id]) }
    failure ->(options, **) { options['errors'] = 'user does not exist' }

    step ->(model:, params:, **) { model.roles << Role.where(id: params[:roles]) }
  end
end
