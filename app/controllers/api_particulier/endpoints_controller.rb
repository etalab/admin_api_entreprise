class APIParticulier::EndpointsController < APIParticulierController
  before_action :extract_endpoint, except: :index

  def index
    @endpoints = APIParticulier::Endpoint.all.reject(&:deprecated?)

    render 'index', layout: 'api_particulier/no_container'
  end

  def show; end

  def example; end

  private

  def extract_endpoint
    @endpoint = APIParticulier::Endpoint.find(params[:uid])
  end
end
