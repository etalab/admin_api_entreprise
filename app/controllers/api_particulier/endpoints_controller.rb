class APIParticulier::EndpointsController < APIParticulierController
  before_action :extract_endpoint, except: :index

  def index
    @endpoints = APIParticulier::Endpoint.all.reject(&:deprecated?)
      .sort { |endpoint1, endpoint2| helpers.order_by_position_or_status(endpoint1, endpoint2) }

    render 'index', layout: 'api_particulier/no_container'
  end

  def show; end

  def example
    render 'shared/endpoints/example'
  end

  private

  def extract_endpoint
    @endpoint = APIParticulier::Endpoint.find(params[:uid])
  end
end
