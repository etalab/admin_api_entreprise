class Token::SendEmailWithMagicLink < ApplicationInteractor
  def call
    token_mailer_klass.magic_link(context.magic_link, context.host).deliver_later
  end

  private

  def token_mailer_klass
    if host.include?('particulier')
      APIParticulier::TokenMailer
    elsif host.include?('entreprise')
      APIEntreprise::TokenMailer
    else
      raise "Unknown host for token mailer: #{host}"
    end
  end

  def host
    context.host
  end
end
