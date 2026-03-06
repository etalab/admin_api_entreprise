class APIParticulier::DelegationsController < APIParticulier::AuthenticatedUsersController
  include DelegationsManagement
end
