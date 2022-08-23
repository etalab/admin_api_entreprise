# frozen_string_literal: true

class APIEntreprise::CasUsagesController < APIEntrepriseController
  layout 'api_entreprise/no_container'

  def index; end

  def show
    @data = I18n.t("api_entreprise.cas_usages_entries.#{params[:uid]}", raise: true)
  rescue I18n::MissingTranslationData
    redirect_to root_path
  end
end
