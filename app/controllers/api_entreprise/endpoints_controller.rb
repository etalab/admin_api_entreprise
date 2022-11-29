class APIEntreprise::EndpointsController < APIEntrepriseController
  before_action :extract_endpoint, except: :index

  def index
    @endpoints = Endpoint.all

    render 'index', layout: 'api_entreprise/no_container'
  end

  def show; end

  def example
    return unless @endpoint.dummy?

    redirect_to endpoint_path(uid: @endpoint.uid)
  end

  private

  def extract_endpoint
    @endpoint = Endpoint.find(params[:uid])
  end
end
