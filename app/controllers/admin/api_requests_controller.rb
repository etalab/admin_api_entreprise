module Admin
  class APIRequestsController < AdminController
    AVAILABLE_APIS = [
      ['API Entreprise', 'api_entreprise'],
      ['API Particulier', 'api_particulier']
    ].freeze

    before_action :set_common_variables

    def index
      @result = nil
    end

    def create
      endpoint = @endpoints.find { |e| e.path == @selected_endpoint }
      return render :index unless endpoint

      @result = Siade::ManualRequest.new(
        endpoint_path: endpoint.path,
        params: endpoint.transform_params(endpoint_params),
        api: endpoint.api
      ).call

      render :index
    end

    private

    def set_common_variables
      @apis = AVAILABLE_APIS
      @selected_api = params[:api] || 'api_entreprise'
      @endpoints = OpenAPIEndpoint.all_for_api(@selected_api)
      @selected_endpoint = params[:endpoint_uid]
    end

    def endpoint_params
      params.permit!.to_h.except(:controller, :action, :api, :endpoint_uid, :authenticity_token, :commit)
    end
  end
end
