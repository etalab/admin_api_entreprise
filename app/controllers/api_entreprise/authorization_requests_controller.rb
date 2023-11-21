# frozen_string_literal: true

class APIEntreprise::AuthorizationRequestsController < APIEntreprise::AuthenticatedUsersController
  include AuthorizationRequestsManagement
end
