require 'rails_helper'

describe JwtApiEntrepriseMailer, type: :mailer do
  describe '#expiration_notice' do
    subject { described_class.expiration_notice(jwt, nb_days) }

    let(:jwt) { create(:jwt_api_entreprise, :with_contacts) }
    let(:user) { jwt.user }
    let(:nb_days) { '4000' }

    its(:subject) { is_expected.to eq("API Entreprise - Votre jeton expire dans #{nb_days} jours !") }
    its(:from) { is_expected.to include(Rails.configuration.emails_sender_address) }

    describe 'notification recipients' do
      it 'sends the email to the account owner' do
        subject

        expect(subject.to).to include(user.email)
      end

      it 'sends the email to all jwt\'s contacts' do
        contacts_emails = jwt.contacts.pluck(:email).uniq

        expect(subject.to).to include(*contacts_emails)
      end
    end

    it 'contains the number of remaining days' do
      tested_corpus = "Un de vos jetons d'accès à API Entreprise expire dans moins de #{nb_days} jours."

      expect(subject.html_part.decoded).to include(tested_corpus)
      expect(subject.text_part.decoded).to include(tested_corpus)
    end

    it 'contains the JWT information' do
      jwt_info = "le jeton attribué dans le cadre d'utilisation \"#{jwt.subject}\" (id : #{jwt.id}) ne sera bientôt plus valide !"

      expect(subject.html_part.decoded).to include(jwt_info)
      expect(subject.text_part.decoded).to include(jwt_info)
    end

    it 'contains the exact expiration time of the JWT' do
      expiration_datetime = jwt.user_friendly_exp_date
      tested_corpus = "Passée la date du #{expiration_datetime} les appels à API Entreprise avec ce jeton seront rejetés."

      expect(subject.html_part.decoded).to include(tested_corpus)
      expect(subject.text_part.decoded).to include(tested_corpus)
    end

    it 'contains the team email address to request a renewal' do
      renewal_process = "Merci de contacter le support à l\'adresse <a href=\"mailto:#{Rails.configuration.emails_sender_address}\">#{Rails.configuration.emails_sender_address}</a> afin de procéder au renouvellement"

      expect(subject.html_part.decoded).to include(renewal_process)
      expect(subject.text_part.decoded).to include(renewal_process)
    end
  end

  describe '#creation_notice' do
    let(:jwt) { create(:jwt_api_entreprise, :with_contacts) }

    subject { described_class.creation_notice(jwt) }

    its(:subject) { is_expected.to eq 'API Entreprise - Création d\'un nouveau token' }
    its(:from) { is_expected.to include(Rails.configuration.emails_sender_address) }

    it 'sends the email to all contacts (including the account owner)' do
      account_owner_email = jwt.user.email
      jwt_contacts_emails = jwt.contacts.pluck(:email).uniq

      expect(subject.to).to include(account_owner_email, *jwt_contacts_emails)
    end

    it 'contains the token_creation_notice' do
      notice = 'Un nouveau token est disponible dans votre espace client'

      expect(subject.html_part.decoded).to include(notice)
      expect(subject.text_part.decoded).to include(notice)
    end

    it 'contains the list of all roles' do
      jwt.roles.each do |role|
        expect(subject.html_part.decoded).to include(role.name)
        expect(subject.text_part.decoded).to include(role.name)
      end
    end

    it 'contains the link to the token' do
      token_url = "https://sandbox.dashboard.entreprise.api.gouv.fr/admin/users/#{jwt.user.id}/tokens/"
      expect(subject.html_part.decoded).to include(token_url)
      expect(subject.text_part.decoded).to include(token_url)
    end

    it 'contains info regarding the current account access' do
      notice = "parmi les contacts pour le compte #{jwt.user.email}"

      expect(subject.html_part.decoded).to include(notice)
      expect(subject.text_part.decoded).to include(notice)
    end
  end
end
