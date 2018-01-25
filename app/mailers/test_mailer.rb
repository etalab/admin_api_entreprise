class TestMailer < ApplicationMailer
  default from: 'brindu@entreprise.api.gouv.fr'
  layout 'mailer'

  def test
    mail(to: 'tech@entreprise.api.gouv.fr', subject: 'Yeah Admin rocks!')
  end
end
