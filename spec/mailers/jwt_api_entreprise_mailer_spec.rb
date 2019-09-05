require 'rails_helper'

describe JwtApiEntrepriseMailer, type: :mailer do
  describe '#expiration_notice' do
    subject { described_class.expiration_notice(jwt, nb_days) }

    let(:user) { create(:user, :with_jwt) }
    let(:jwt) { user.jwt_api_entreprise.first }
    let(:nb_days) { '4000' }

    its(:subject) { is_expected.to eq("API Entreprise - Expiration de votre jeton d'accès dans #{nb_days} jours !") }
    its(:from) { is_expected.to include('tech@entreprise.api.gouv.fr') }

    it 'sends the email to the account owner' do
      subject

      expect(subject.to).to include(user.email)
    end

    it 'contains the JWT information' do
      jwt_info = "le jeton utilisé dans le cadre \"#{jwt.subject}\" (id : #{jwt.id}) ne sera plus valide dans #{nb_days} jours !"

      expect(subject.html_part.decoded).to include(jwt_info)
      expect(subject.text_part.decoded).to include(jwt_info)
    end

    it 'contains the team email address to request a renewal' do
      renewal_process = 'Merci de contacter le support à l\'adresse <a href="mailto:tech@entreprise.api.gouv.fr">tech@entreprise.api.gouv.fr</a> afin de procéder au renouvellement'

      expect(subject.html_part.decoded).to include(renewal_process)
      expect(subject.text_part.decoded).to include(renewal_process)
    end
  end
end
