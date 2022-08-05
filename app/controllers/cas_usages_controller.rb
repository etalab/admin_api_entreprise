# frozen_string_literal: true

class CasUsagesController < ApplicationController
  layout 'no_container'

  def index; end

  def show
    @cas_usage_tag = request.original_url.split('/').last
    @cas_usage_name = cas_usage_tag_to_name[@cas_usage_tag.to_sym]
    @cas_usage = I18n.t("cas_usages.#{@cas_usage_tag}")
  end

  private

  def cas_usage_tag_to_name
    {
      marches_publics: 'Marchés publics',
      subventions: 'Aides publiques',
      fraude: 'Détection de la fraude',
      formulaire: "Préremplissage d'un formulaire"
    }
  end
end
