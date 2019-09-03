module User::Operation
  class AddRoles < Trailblazer::Operation
    step self::Contract::Validate(constant: User::Contract::AddRoles)
    step ->(options, params:, **) { options[:model] = User.find_by(id: params[:id]) }
    fail ->(options, **) { options['errors'] = 'user does not exist' }

    step ->(options, model:, params:, **) { model.roles << Role.where(id: params[:roles]) }
  end
end
