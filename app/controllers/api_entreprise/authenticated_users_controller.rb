class APIEntreprise::AuthenticatedUsersController < APIEntrepriseController
  include AuthenticatedUserManagement

  layout 'api_entreprise/authenticated_user'
end
