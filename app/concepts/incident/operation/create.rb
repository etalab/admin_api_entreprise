class Incident
  module Operation
    class Create < Trailblazer::Operation
      step Nested(Incident::Operation::Save)
    end
  end
end
