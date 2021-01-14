module User::Operation
  class CreateGhost < Trailblazer::Operation
    step Model(User, :new)
    step Contract::Build(constant: User::Contract::CreateGhost)
    step Contract::Validate()
    step Contract::Persist()
  end
end
