class UserMailer < ApplicationMailer
  def confirm_account_action(user)
    subject = 'API Entreprise - Activation de compte utilisateur'

    @user = user
    @confirmation_url = Rails.configuration.account_confirmation_url.to_s + "?confirmation_token=#{@user.confirmation_token}"
    mail(to: @user.email, subject: subject)
  end

  def confirm_account_notice(user)
    @user = user
    subject = 'API Entreprise - Activation de compte utilisateur'

    mail(to: confirm_account_notice_recipients, subject: subject)
  end

  def token_creation_notice(new_token)
    @user = new_token.user
    @url_jwt = Rails.configuration.account_tokens_list_url.to_s % [@user.id]
    @jwt = new_token

    subject = 'API Entreprise - Création d\'un nouveau token'

    mail(to: token_creation_notice_recipients, subject: subject)
  end

  private

  def confirm_account_notice_recipients
    recipients = @user.contacts.pluck(:email).uniq
    recipients.delete(@user.email) if recipients.count > 1
    recipients
  end

  def token_creation_notice_recipients
    recipients = @user.contacts.pluck(:email)
    recipients << @user.email
    recipients.uniq
  end
end
