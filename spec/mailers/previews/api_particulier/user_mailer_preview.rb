class APIParticulier::UserMailerPreview < ActionMailer::Preview
  def transfer_ownership
    new_owner = User.first
    old_owner = User.last

    APIParticulier::UserMailer.transfer_ownership(old_owner, new_owner, old_owner.authorization_requests.for_api('particulier'), 'api_particulier')
  end

  def notify_datapass_for_data_reconciliation
    APIParticulier::UserMailer.notify_datapass_for_data_reconciliation(user, 'api_particulier')
  end

  private

  def to
    'example@fake.com'
  end

  def user
    User.first
  end
end
