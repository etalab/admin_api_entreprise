require 'csv'

class APIParticulier::NewTokensController < APIParticulier::AuthenticatedUsersController
  def download
    send_data TokenExport.new(current_user).perform, filename: 'new_tokens.csv'
  end
end
