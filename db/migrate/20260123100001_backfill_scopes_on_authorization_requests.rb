class BackfillScopesOnAuthorizationRequests < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    AuthorizationRequest.find_each do |ar|
      next if ar.token.blank?

      ar.update!(scopes: ar.token.scopes)
    end
  end

  def down
    AuthorizationRequest.update_all(scopes: []) # rubocop:disable Rails/SkipsModelValidations
  end
end
