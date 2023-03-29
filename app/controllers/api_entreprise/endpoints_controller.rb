class APIEntreprise::EndpointsController < APIEntrepriseController
  before_action :extract_endpoint, except: :index

  def index
    @endpoints = APIEntreprise::Endpoint.all.reject(&:deprecated?)

    render 'index', layout: 'api_entreprise/no_container'
  end

  def show
    @active_endpoints = EndpointDecorator.decorate_collection(APIEntreprise::Endpoint.all.reject(&:deprecated))
  end

  def example
    return unless @endpoint.dummy?

    redirect_to endpoint_path(uid: @endpoint.uid)
  end

  private

  def extract_endpoint
    @endpoint = APIEntreprise::Endpoint.find(params[:uid])
  end
end
