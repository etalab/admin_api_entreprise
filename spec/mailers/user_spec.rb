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

  describe 'token_creation_notice' do
    subject { described_class.token_creation_notice new_token }

    let(:user) { create :user, :with_contacts, :with_jwt }
    let(:new_token) { user.jwt_api_entreprise.first }

    its(:subject) { is_expected.to eq 'API Entreprise - Création d\'un nouveau token' }
    its(:from) { is_expected.to eq ['tech@entreprise.api.gouv.fr'] }

    it 'sends the email to all contacts (including the account owner)' do
      user.contacts.first.update email: user.email
      all_emails = user.contacts.pluck(:email) << user.email
      expect(subject.to).to eq all_emails.uniq
    end

    it 'contains the token_creation_notice' do
      notice = 'Un nouveau token est disponible dans votre espace client'

      expect(subject.html_part.decoded).to include notice
      expect(subject.text_part.decoded).to include notice
    end

    it 'contains the list of all roles' do
      new_token.roles.each do |role|
        expect(subject.html_part.decoded).to include role.name
        expect(subject.text_part.decoded).to include role.name
      end
    end

    it 'contains the link to the token' do
      token_url = "https://sandbox.dashboard.entreprise.api.gouv.fr/admin/users/#{user.id}/tokens/"
      expect(subject.html_part.decoded).to include token_url
      expect(subject.text_part.decoded).to include token_url
    end

    it 'contains info regarding the current account access' do
      notice = "parmi les contacts pour le compte #{user.email}"

      expect(subject.html_part.decoded).to include notice
      expect(subject.text_part.decoded).to include notice
    end
  end
end
