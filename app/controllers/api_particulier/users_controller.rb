class APIParticulier::UsersController < APIParticulier::AuthenticatedUsersController
  include UserManagement
end
