class ValidateEditorDelegationsForeignKeys < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :editor_delegations, :editors
    validate_foreign_key :editor_delegations, :authorization_requests
  end
end
