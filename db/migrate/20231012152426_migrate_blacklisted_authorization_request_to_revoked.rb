class MigrateBlacklistedAuthorizationRequestToRevoked < ActiveRecord::Migration[7.1]
  def change
    AuthorizationRequest.where(status: 'blacklisted').update_all(status: 'revoked')
  end
end
