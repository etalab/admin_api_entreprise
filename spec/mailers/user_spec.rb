require "rails_helper"

describe UserMailer, type: :mailer do
  describe 'confirm account action' do
    subject { UserMailer.confirm_account_action(user) }

    let(:user) { create :user, confirmation_token: 'very_confirm' }

    its(:subject) { is_expected.to eq 'API Entreprise - Activation de compte utilisateur' }
    its(:to) { is_expected.to eq [user.email] }
    its(:from) { is_expected.to include(Rails.configuration.emails_sender_address) }

    it 'contains the user confirmation URL' do
      confirmation_url = "https://sandbox.dashboard.entreprise.api.gouv.fr/account/confirm?confirmation_token=very_confirm"

      expect(subject.html_part.decoded).to include(confirmation_url)
      expect(subject.text_part.decoded).to include(confirmation_url)
    end
  end
end
