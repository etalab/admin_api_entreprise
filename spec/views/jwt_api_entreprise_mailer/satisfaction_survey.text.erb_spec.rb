require 'rails_helper'

RSpec.describe('rendering the mail template') do
  before do
    assign(:jwt, jwt)
    render template: 'jwt_api_entreprise_mailer/satisfaction_survey', formats: [:text]
  end

  let(:jwt) { build(:jwt_api_entreprise) }

  let(:full_message) do
    <<~FULL_MESSAGE.chomp
      Bonjour,

      Il y a quelques jours, votre demande d'accès à l'API Entreprise n°#{jwt.authorization_request_id} a été validée par nos services juridiques.
      Nous aimerions comprendre comment s'est déroulée votre habilitation à l'API Entreprise, et recueillir vos besoins actuels :

      https://startupdetat.typeform.com/to/bFo1H9NJ

      À bientôt,
      Toute l'équipe API Entreprise
    FULL_MESSAGE
  end

  subject do
    rendered
  end

  it 'renders the message' do
    expect(subject).to(match(full_message))
  end
end
