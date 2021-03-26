require 'rails_helper'

RSpec.describe 'rendering the mail template' do
  before do
    assign(:jwt_authorization_request_id, 42)
    render template: 'jwt_api_entreprise_mailer/satisfaction_survey.text.erb'
  end

  let(:full_message) do
    <<~FULL_MESSAGE.chomp
      Bonjour,

      Il y a quelques jours, votre demande d'accès à l'API Entreprise N°42 a été validée par nos services juridiques.
      Nous menons actuellement une enquête pour améliorer notre service, et dans ce cadre, nous aurions aimé avoir votre retour d'expérience.

      Le formulaire suivant, qui devrait vous prendre 5 minutes, nous permettra d'évaluer votre satisfaction sur le parcours d'accès à l'API Entreprise, d'identifier des pistes d'amélioration et de recueillir vos besoins actuels :

      <a href="https://startupdetat.typeform.com/to/bFo1H9NJ">Répondre à l&#39;enquête utilisateur</a>

      Merci par avance pour votre participation,

      Toute l'équipe API Entreprise
    FULL_MESSAGE
  end

  subject do
    rendered
  end

  it 'renders the message' do
    # byebug
    expect(subject).to match full_message
  end
end
