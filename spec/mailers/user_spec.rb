require "rails_helper"

describe UserMailer, type: :mailer do
  describe 'confirm account action' do
    subject { UserMailer.confirm_account_action(user) }

    let(:user) { create :user, confirmation_token: 'very_confirm' }

    its(:subject) { is_expected.to eq 'API Entreprise - Activation de compte utilisateur' }
    its(:to) { is_expected.to eq [user.email] }
    its(:from) { is_expected.to eq ['tech@entreprise.api.gouv.fr'] }

    it 'contains the user confirmation URL' do
      confirmation_url = "https://sandbox.dashboard.entreprise.api.gouv.fr/account/confirm?confirmation_token=very_confirm"

      expect(subject.html_part.decoded).to include(confirmation_url)
      expect(subject.text_part.decoded).to include(confirmation_url)
    end
  end

  describe 'confirm account notice' do
    subject { UserMailer.confirm_account_notice user }

    context 'when contact principal is not métier or/and technique' do
      let(:user) do
        user = create :user
        user.contacts = [create_list(:contact, 2), create_list(:tech_contact, 2), create_list(:admin_contact, 2)].flatten
        user
      end

      its(:subject) { is_expected.to eq 'API Entreprise - Activation de compte utilisateur' }
      its(:to) { is_expected.to eq user.contacts.pluck(:email) }
      its(:from) { is_expected.to eq ['tech@entreprise.api.gouv.fr'] }

      it 'contains the confirm account notice' do
        notice = "votre administrateur (#{user.email}) a reçu un e-mail"

        expect(subject.html_part.decoded).to include(notice)
        expect(subject.text_part.decoded).to include(notice)
      end
    end

    context 'when contact principal is also métier or/and technique' do
      let(:other_contacts) { create_list :tech_contact, 2 }
      let(:user) do
        user = UsersFactory.inactive_user
        user.contacts = [create(:tech_contact, email: user.email), other_contacts].flatten
        user
      end

      its(:to) { is_expected.to eq other_contacts.pluck(:email) }
    end
  end
end
