# frozen_string_literal: true

class APIParticulier::CasUsagesController < APIParticulierController
  layout 'api_particulier/no_container'

  def index
    @cas_usages = APIParticulier::CasUsage.all
  end

  def show
    @cas_usage = APIParticulier::CasUsage.find(params[:uid])
    @other_cas_usages = APIParticulier::CasUsage.all - [@cas_usage]
    @active_endpoints = EndpointDecorator.decorate_collection(APIParticulier::Endpoint.all.reject(&:deprecated))
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end
end
