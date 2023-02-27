# frozen_string_literal: true

class APIEntreprise::CasUsagesController < APIEntrepriseController
  layout 'api_entreprise/no_container'

  def index; end

  def show
    @cas_usage = CasUsage.find(params[:uid])
    @other_cas_usages = CasUsage.all - [@cas_usage]
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end
end
