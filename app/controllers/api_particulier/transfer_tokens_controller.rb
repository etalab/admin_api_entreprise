class APIParticulier::TransferTokensController < APIParticulier::AuthenticatedUsersController
  include TransferTokensManagement
end
