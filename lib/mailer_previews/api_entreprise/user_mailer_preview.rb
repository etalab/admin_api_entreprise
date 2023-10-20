class APIEntreprise::UserMailerPreview < ActionMailer::Preview
  def transfer_ownership
    new_owner = User.first
    old_owner = User.last

    APIEntreprise::UserMailer.transfer_ownership(old_owner, new_owner)
  end

  def notify_datapass_for_data_reconciliation
    APIEntreprise::UserMailer.notify_datapass_for_data_reconciliation(user)
  end

  private

  def to
    'example@fake.com'
  end

  def user
    User.first
  end
end
