require "rails_helper"

describe UserMailer, type: :mailer do
  describe '#renew_account_password' do
    let(:user) { create(:user, pwd_renewal_token: 'coucou') }

    subject { described_class.renew_account_password(user) }

    its(:subject) { is_expected.to eq('API Entreprise - Mise à jour de votre mot de passe') }
    its(:to) { is_expected.to eq([user.email]) }
    its(:from) { is_expected.to include(Rails.configuration.emails_sender_address) }

    describe 'body' do
      it 'contains the URL for a password update' do
        reset_pwd_url = "https://sandbox.dashboard.entreprise.api.gouv.fr/account/password_reset?token=coucou"

        expect(subject.html_part.decoded).to include(reset_pwd_url)
        expect(subject.text_part.decoded).to include(reset_pwd_url)
      end

      it 'says the link will expire in 24h' do
        corpus = 'Le lien de renouvellement est valide pendant 24 heures.'

        expect(subject.html_part.decoded).to include(corpus)
        expect(subject.text_part.decoded).to include(corpus)
      end
    end
  end
end
