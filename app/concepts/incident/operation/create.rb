class Incident
  class Create < Trailblazer::Operation
    step Model(Incident, :new)
    step self::Contract::Build(constant: Incident::Contract::Create)
    step self::Contract::Validate()
    step self::Contract::Persist()
  end
end
