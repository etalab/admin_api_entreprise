module Admin
  class APIRequestsController < AdminController
    before_action :set_facade

    def index
      @result = nil
    end

    def create
      @result = @facade.execute_request(endpoint_params)
      render :index
    end

    private

    def set_facade
      @facade = APIRequestFacade.new(
        namespace:,
        selected_endpoint_uid: params[:endpoint_uid]
      )
    end

    def endpoint_params
      params.permit!.to_h.except(:controller, :action, :endpoint_uid, :authenticity_token, :commit)
    end
  end
end
