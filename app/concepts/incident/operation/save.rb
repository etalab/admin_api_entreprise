class Incident
  module Operation
    class Save < Trailblazer::Operation
      success ->(options, model: nil, **) { options[:model] = Incident.new if model.nil? }
      step self::Contract::Build(constant: Incident::Contract::Save)
      step self::Contract::Validate()
      step self::Contract::Persist()
    end
  end
end
