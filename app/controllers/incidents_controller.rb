class IncidentsController < ApplicationController
  skip_before_action :jwt_authenticate!, only: [:index]

  def index
    incidents = Incident.all
    render json: incidents, each_serializer: IncidentIndexSerializer, status: 200
  end

  def create
    authorize :admin, :admin?
    result = Incident::Create.call(params: params)

    if result.success?
      render json: result[:model], status: 201
    else
      errors = result['result.contract.default'].errors
      render json: { errors: errors }, status: 422
    end
  end
end
