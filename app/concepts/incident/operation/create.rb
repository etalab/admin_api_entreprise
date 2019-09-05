class Incident
  module Operation
    class Create < Trailblazer::Operation
      step Subprocess(Incident::Operation::Save)
    end
  end
end
