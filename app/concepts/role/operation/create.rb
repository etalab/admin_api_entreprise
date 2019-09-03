module Role::Operation
  class Create < Trailblazer::Operation
    step Model(Role, :new)
    step self::Contract::Validate(constant: Role::Contract::Create)
    step :persist

    def persist(options, model:, params:, **)
      model.name = params[:name]
      model.code = params[:code]
      model.save!
    end
  end
end
