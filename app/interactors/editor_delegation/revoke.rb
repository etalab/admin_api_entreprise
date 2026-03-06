class EditorDelegation::Revoke < ApplicationInteractor
  def call
    context.delegation = find_delegation
    context.delegation.update!(revoked_at: Time.zone.now)
  rescue ActiveRecord::RecordNotFound
    fail!('Delegation not found', :warning, delegation_id: context.delegation_id)
  end

  private

  def find_delegation
    context.authorization_request.editor_delegations.active.find(context.delegation_id)
  end
end
