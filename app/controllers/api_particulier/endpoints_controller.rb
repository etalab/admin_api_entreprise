class APIParticulier::EndpointsController < APIParticulierController
  before_action :extract_endpoint, except: :index

  def index
    @endpoints = APIParticulier::Endpoint.all.sort { |endpoint1, endpoint2| helpers.order_by_position_or_status(endpoint1, endpoint2) }

    render 'index', layout: 'api_particulier/no_container'
  end

  def show; end

  def example
    render 'shared/endpoints/example'
  end

  private

  def extract_endpoint
    @endpoint = endpoint_class.find(params[:uid])
  end

  def endpoint_class
    return APIParticulier::EndpointV2 if params[:uid].include?('/v2/')

    APIParticulier::Endpoint
  end
end
