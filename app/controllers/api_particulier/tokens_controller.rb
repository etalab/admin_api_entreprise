class APIParticulier::TokensController < APIParticulier::AuthenticatedUsersController
  include TokensManagement

  before_action :extract_token
end
