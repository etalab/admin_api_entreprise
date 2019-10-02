require 'rails_helper'

# rubocop:disable Metrics/LineLength
describe JwtApiEntrepriseMailer, type: :mailer do
  describe '#expiration_notice' do
    subject { described_class.expiration_notice(jwt, nb_days) }

    let(:user) { create(:user, :with_jwt, :with_contacts) }
    let(:jwt) { user.jwt_api_entreprise.first }
    let(:nb_days) { '4000' }

    its(:subject) { is_expected.to eq("API Entreprise - Votre jeton expire dans #{nb_days} jours !") }
    its(:from) { is_expected.to include(Rails.configuration.emails_sender_address) }

    describe 'notification recipients' do
      it 'sends the email to the account owner' do
        subject

        expect(subject.to).to include(user.email)
      end

      it 'sends the email to the business contact' do
        # TODO This could be better and clearer here, be patient it will be refactor soon
        business_addresses = user.contacts.where(contact_type: 'admin').pluck(:email).uniq
        subject

        expect(subject.to).to include(*business_addresses)
      end

      it 'send the email to the tech contact' do
        # TODO This could be better and clearer here, be patient it will be refactor soon
        tech_addresses = user.contacts.where(contact_type: 'tech').pluck(:email).uniq
        subject

        expect(subject.to).to include(*tech_addresses)
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
end
# rubocop:enable Metrics/LineLength
