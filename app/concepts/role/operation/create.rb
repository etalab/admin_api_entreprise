module Role::Operation
  class Create < Trailblazer::Operation
    step Model(Role, :new)
    step self::Contract::Build(constant: Role::Contract::Create)
    step self::Contract::Validate()
    step self::Contract::Persist()
  end
end
