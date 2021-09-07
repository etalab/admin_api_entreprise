# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::ExtractMailjetVariables, type: :interactor do
  subject { described_class.call(datapass_webhook_params.merge(authorization_request: authorization_request)) }

  let(:datapass_webhook_params) { build(:datapass_webhook, event: event) }
  let(:authorization_request) { create(:authorization_request) }

  let(:event) { 'created' }

  it { is_expected.to be_a_success }

  it 'creates a hash with all required variables extracted from datapass webhook payload' do
    expect(subject.mailjet_variables).to be_present

    expect(subject.mailjet_variables['authorization_request_id']).to eq(authorization_request.external_id)
    expect(subject.mailjet_variables['authorization_request_intitule']).to eq(authorization_request.intitule)
    expect(subject.mailjet_variables['authorization_request_description']).to eq(authorization_request.description)

    expect(subject.mailjet_variables['demandeur_first_name']).to eq(authorization_request.user.first_name)
    expect(subject.mailjet_variables['demandeur_last_name']).to eq(authorization_request.user.last_name)
    expect(subject.mailjet_variables['demandeur_email']).to eq(authorization_request.user.email)

    expect(subject.mailjet_variables['token_roles']).to be_nil
  end

  context 'when event is from an instructor' do
    let(:event) { 'refuse_application' }

    it 'sets instructor first and last name' do
      expect(subject.mailjet_variables['instructor_first_name']).to eq('Instructor first name')
      expect(subject.mailjet_variables['instructor_last_name']).to eq('Instructor last name')
    end
  end

  context 'when event is not from an instructor' do
    let(:event) { 'created' }

    it 'does not set instructor first and last name' do
      expect(subject.mailjet_variables['instructor_first_name']).to be_nil
      expect(subject.mailjet_variables['instructor_last_name']).to be_nil
    end
  end

  context 'when authorization request has a token' do
    let!(:jwt_api_entreprise) { create(:jwt_api_entreprise, authorization_request: authorization_request) }

    before do
      %w[
        uptime
        entreprise
        liasse_fiscale
      ].each do |code|
        jwt_api_entreprise.roles << create(:role, code: code)
      end

      create(:role, code: 'etablissement')
    end

    it 'sets token_roles with these values, excluding uptime' do
      expect(subject.mailjet_variables['token_role_uptime']).to be_nil
      expect(subject.mailjet_variables['token_role_entreprise']).to eq 'true'
      expect(subject.mailjet_variables['token_role_liasse_fiscale']).to eq 'true'

      expect(subject.mailjet_variables['token_role_etablissement']).to eq 'false'
    end
  end

  context 'when authorization request has contacts' do
    let(:authorization_request) { create(:authorization_request, :with_contacts) }

    it 'adds contact metier and technique first, last name and email' do
      %w[
        technique
        metier
      ].each do |contact_kind|
        expect(subject.mailjet_variables["contact_#{contact_kind}_first_name"]).to be_present
        expect(subject.mailjet_variables["contact_#{contact_kind}_last_name"]).to be_present
        expect(subject.mailjet_variables["contact_#{contact_kind}_email"]).to be_present
      end
    end
  end
end
