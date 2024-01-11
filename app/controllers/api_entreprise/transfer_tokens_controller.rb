class APIEntreprise::TransferTokensController < APIEntreprise::AuthenticatedUsersController
  include TransferTokensManagement
end
