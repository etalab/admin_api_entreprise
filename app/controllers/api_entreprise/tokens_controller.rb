class APIEntreprise::TokensController < APIEntreprise::AuthenticatedUsersController
  include TokensManagement

  before_action :extract_token
end
