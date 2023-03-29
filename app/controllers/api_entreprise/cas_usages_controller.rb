# frozen_string_literal: true

class APIEntreprise::CasUsagesController < APIEntrepriseController
  layout 'api_entreprise/no_container'

  def index
    @cas_usages = APIEntreprise::CasUsage.all
  end

  def show
    @cas_usage = APIEntreprise::CasUsage.find(params[:uid])
    @other_cas_usages = APIEntreprise::CasUsage.all - [@cas_usage]
    @active_endpoints = EndpointDecorator.decorate_collection(APIEntreprise::Endpoint.all.reject(&:deprecated))
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end
end
