# frozen_string_literal: true

class APIEntreprise::CasUsagesController < APIEntrepriseController
  include CasUsagesManagement

  layout 'api_entreprise/no_container'
end
