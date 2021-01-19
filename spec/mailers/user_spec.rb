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

  describe '#transfer_ownership' do
    let(:new_owner) { create(:user) }
    let(:old_owner) { create(:user) }

    subject { described_class.transfer_ownership(old_owner, new_owner) }

    its(:subject) { is_expected.to eq('API Entreprise - Délégation d\'accès') }
    its(:to) { is_expected.to eq([new_owner.email]) }
    its(:from) { is_expected.to include(Rails.configuration.emails_sender_address) }

    describe 'email body' do
      it 'contains the previous owner email address' do
        expect(subject.html_part.decoded).to include(old_owner.email)
        expect(subject.text_part.decoded).to include(old_owner.email)
      end

      it 'notifies the user to login to access his tokens' do
        signin_link = 'https://dashboard.entreprise.api.gouv.fr/login'

        expect(subject.html_part.decoded).to include(signin_link)
        expect(subject.text_part.decoded).to include(signin_link)
      end

      context 'when the new owner already has an API Gouv account' do
        before { new_owner.oauth_api_gouv_id = 12 }

        it 'informs the user he will need his API Gouv account' do
          expect(subject.html_part.decoded).to include(new_owner.email)
          expect(subject.text_part.decoded).to include(new_owner.email)
        end
      end

      context 'when the new owner does not have an API Gouv account' do
        before { new_owner.oauth_api_gouv_id = nil }

        it 'informs an API Gouv account is needed' do
          signup_link = 'https://auth.api.gouv.fr/users/sign-up'

          expect(subject.html_part.decoded).to include(signup_link)
          expect(subject.text_part.decoded).to include(signup_link)
        end

        it 'informs to use the same email address' do
          expect(subject.html_part.decoded).to include(new_owner.email)
          expect(subject.text_part.decoded).to include(new_owner.email)
        end

        it 'informs to use the same siret' do
          expect(subject.html_part.decoded).to include(new_owner.context)
          expect(subject.text_part.decoded).to include(new_owner.context)
        end
      end
    end
  end

  describe '#notify_datapass_for_data_reconciliation' do
    let(:user) { create(:user, :with_jwt) }

    subject { described_class.notify_datapass_for_data_reconciliation(user) }

    its(:subject) { is_expected.to eq('API Entreprise - Réconciliation de demandes d\'accès à un nouvel usager') }
    its(:to) { is_expected.to eq(['contact@api.gouv.fr']) }
    its(:from) { is_expected.to include(Rails.configuration.emails_sender_address) }

    it 'contains the user email address' do
      expect(subject.html_part.decoded).to include(user.email)
      expect(subject.text_part.decoded).to include(user.email)
    end

    it 'contains the user API Gouv ID' do
      expect(subject.html_part.decoded).to include(user.oauth_api_gouv_id.to_s)
      expect(subject.text_part.decoded).to include(user.oauth_api_gouv_id.to_s)
    end

    it 'contains the user\'s JWT requests ID' do
      authorization_requests_ids = user.jwt_api_entreprise.pluck(:authorization_request_id)
      authorization_requests_ids.map!(&:to_i)

      expect(subject.html_part.decoded).to include(authorization_requests_ids.to_s)
      expect(subject.text_part.decoded).to include(authorization_requests_ids.to_s)
    end
  end
end
