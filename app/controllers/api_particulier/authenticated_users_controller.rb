class APIParticulier::AuthenticatedUsersController < APIParticulierController
  include AuthenticatedUserManagement

  helper_method :tokens_to_export?

  def tokens_to_export?
    TokenExport.new(current_user).tokens_to_export?
  end
end
