require "rails_helper"

describe UserMailer, type: :mailer do
  describe 'confirmation' do
    let(:user) { UsersFactory.inactive_user }
    subject { UserMailer.confirmation_request(user) }

    its(:subject) { is_expected.to eq 'API Entreprise - Activation de compte utilisateur' }
    its(:to) { is_expected.to eq [user.email] }
    its(:from) { is_expected.to eq ['no-reply@entreprise.api.gouv.fr'] }

    it 'contains the user confirmation URL' do
      confirmation_url = "https://sandbox.dashboard.entreprise.api.gouv.fr/#/account/confirm?confirmation_token=#{user.confirmation_token}"

      expect(subject.body.encoded).to include(confirmation_url)
    end
  end
end
