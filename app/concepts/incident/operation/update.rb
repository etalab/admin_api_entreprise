class Incident
  module Operation
    class Update < Trailblazer::Operation
      step Model(Incident, :find_by)
      fail ->(options, params:, **) { options[:errors] = "Incident with id `#{params[:id]}` does not exist." }
      step Nested(Incident::Operation::Save)
    end
  end
end
