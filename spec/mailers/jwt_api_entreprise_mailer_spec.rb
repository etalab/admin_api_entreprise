require 'rails_helper'

RSpec.describe JwtAPIEntrepriseMailer, type: :mailer do
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
