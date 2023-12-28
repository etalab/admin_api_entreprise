class APIEntreprise::ErrorsController < APIEntrepriseController
  include GlobalHTTPErrorsManagement

  layout 'api_entreprise/no_container'
end
