class Incident
  module Operation
    class Update < Trailblazer::Operation
      step Model(Incident, :find_by)
      fail :log_incident_not_found
      step Subprocess(Incident::Operation::Save)

      def log_incident_not_found(options, params:, **)
        options[:errors] = "Incident with id `#{params[:id]}` does not exist."
      end
    end
  end
end
