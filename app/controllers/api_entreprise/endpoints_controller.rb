class APIEntreprise::EndpointsController < APIEntrepriseController
  before_action :extract_endpoint, except: :index

  def index
    @endpoints = APIEntreprise::Endpoint.all.reject(&:deprecated?)
      .sort { |endpoint1, endpoint2| helpers.order_by_position_or_status(endpoint1, endpoint2) }

    render 'index', layout: 'api_entreprise/no_container'
  end

  def show; end

  def example
    if @endpoint.dummy?
      redirect_to endpoint_path(uid: @endpoint.uid)
    else
      render 'shared/endpoints/example'
    end
  end

  private

  def extract_endpoint
    @endpoint = APIEntreprise::Endpoint.find(params[:uid])
  end
end
