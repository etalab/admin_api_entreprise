require 'rails_helper'

describe JwtApiEntrepriseMailer, type: :mailer do
  describe '#expiration_notice' do
    subject { described_class.expiration_notice(jwt, nb_days) }

    let(:user) { create(:user, :with_jwt) }
    let(:jwt) { user.jwt_api_entreprise.first }
    let(:nb_days) { '4000' }

    its(:subject) { is_expected.to eq("API Entreprise - Votre jeton expire dans #{nb_days} jours !") }
    its(:from) { is_expected.to include('tech@entreprise.api.gouv.fr') }

    it 'sends the email to the account owner' do
      subject

      expect(subject.to).to include(user.email)
    end

    it 'contains the number of remaining days' do
      tested_corpus = "Un de vos jetons d'accès à API Entreprise expire dans moins de #{nb_days} jours."

      expect(subject.html_part.decoded).to include(tested_corpus)
      expect(subject.text_part.decoded).to include(tested_corpus)
    end

    it 'contains the JWT information' do
      jwt_info = "le jeton utilisé dans le cadre \"#{jwt.subject}\" (id : #{jwt.id}) ne sera bientôt plus valide !"

      expect(subject.html_part.decoded).to include(jwt_info)
      expect(subject.text_part.decoded).to include(jwt_info)
    end

    it 'contains the exact expiration time of the JWT' do
      expiration_datetime = Time.at(jwt.exp).to_datetime
      tested_corpus = "Passée la date du #{expiration_datetime} les appels à API Entreprise seront rejetés."

      expect(subject.html_part.decoded).to include(tested_corpus)
      expect(subject.text_part.decoded).to include(tested_corpus)
    end

    it 'contains the team email address to request a renewal' do
      renewal_process = 'Merci de contacter le support à l\'adresse <a href="mailto:tech@entreprise.api.gouv.fr">tech@entreprise.api.gouv.fr</a> afin de procéder au renouvellement'

      expect(subject.html_part.decoded).to include(renewal_process)
      expect(subject.text_part.decoded).to include(renewal_process)
    end
  end
end
