require 'rails_helper'

RSpec.describe JwtAPIEntrepriseMailer, type: :mailer do
  describe 'Expiration notices (old and new)' do
    let(:jwt) { create(:jwt_api_entreprise, :with_contacts) }
    let(:user) { jwt.user }
    let(:nb_days) { '4000' }

    shared_examples 'expiration notice' do
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
        expiration_datetime = friendly_format_from_timestamp(jwt.exp)
        tested_corpus = "Passée la date du #{expiration_datetime} les appels à API Entreprise avec ce jeton seront rejetés."

        expect(subject.html_part.decoded).to include(tested_corpus)
        expect(subject.text_part.decoded).to include(tested_corpus)
      end
    end

    describe '#expiration_notice' do
      subject { described_class.expiration_notice(jwt, nb_days) }

      it_behaves_like 'expiration notice'

      it 'contains the renewal process instructions' do
        instructions = "Le formulaire a été pré-rempli avec les données fournies lors de votre précédente demande d'accès, veuillez cependant vérifier que les informations sont à jour (notamment les coordonnées de contact) et les re-saisir dans le cas contraire. De plus, de nouvelles sources de données auxquelles vous auriez accès sont potentiellement disponibles depuis votre dernière demande !"

        expect(subject.html_part.decoded).to include(instructions.unindent)
        expect(subject.text_part.decoded).to include(instructions.unindent)
      end

      it 'contains the team email address' do
        renewal_process = "N'hésitez pas à contacter le support en répondant directement à cet email si vous avez la moindre question."

        expect(subject.html_part.decoded).to include(renewal_process)
        expect(subject.text_part.decoded).to include(renewal_process)
      end

      it 'contains the URL to the JWT\'s renewal request form' do
        expect(subject.html_part.decoded).to include(jwt.renewal_url)
        expect(subject.text_part.decoded).to include(jwt.renewal_url)
      end
    end
  end

  describe '#satisfaction_survey' do
    subject(:mailer) { described_class.satisfaction_survey(jwt_api_entreprise) }

    let(:jwt_api_entreprise) { create(:jwt_api_entreprise) }

    its(:subject) { is_expected.to eq('API Entreprise - Comment s\'est déroulée votre demande d\'accès ?') }
    its(:from) { is_expected.to include(Rails.configuration.emails_sender_address) }
    its(:to) { is_expected.to contain_exactly(jwt_api_entreprise.user.email) }
  end

  describe '#magic_link' do
    subject(:mailer) { described_class.magic_link(email, jwt) }

    let(:email) { 'muchemail@wow.com' }
    let(:jwt) { create(:jwt_api_entreprise, :with_magic_link) }

    its(:subject) { is_expected.to eq('API Entreprise - Lien d\'accès à votre jeton !') }
    its(:from) { is_expected.to include(Rails.configuration.emails_sender_address) }
    its(:to) { is_expected.to contain_exactly(email) }

    it 'contains the magic link to the jwt' do
      magic_link_path = Rails.configuration.jwt_magic_link_url
      magic_link_url = "#{magic_link_path}?token=#{jwt.magic_link_token}"

      expect(subject.html_part.decoded).to include(magic_link_url)
      expect(subject.text_part.decoded).to include(magic_link_url)
    end
  end
end
