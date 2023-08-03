# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::APIEntreprise, type: :interactor do
  subject { described_class.call(datapass_webhook_params) }

  let(:datapass_webhook_params) do
    build(:datapass_webhook,
      event: 'validate_application',
      demarche: 'editeurs',
      authorization_request_attributes: {
        copied_from_enrollment_id: previous_enrollment_id
      })
  end

  let(:previous_enrollment_id) { rand(9001).to_s }

  let(:token) { create(:token) }

  before do
    allow(Mailjet::Contactslist_managemanycontacts).to receive(:create)

    create(:authorization_request, external_id: previous_enrollment_id, tokens: [token])
  end

  it_behaves_like 'datapass webhooks'

  it 'creates an authorization request with entreprise api and demarche' do
    expect(subject.authorization_request.api).to eq('entreprise')
    expect(subject.authorization_request.demarche).to eq('editeurs')
  end

  describe 'when contact metier is empty (non-regression test)' do
    before do
      datapass_webhook_params['data']['pass']['team_members'].each do |team_member_json|
        next unless team_member_json['type'] == 'contact_metier'

        team_member_json['family_name'] = nil
        team_member_json['given_name'] = nil
        team_member_json['email'] = nil
      end
    end

    it 'creates token for API Entreprise and stores id in token_id' do
      expect {
        subject
      }.to change(Token, :count).by(1)

      token = Token.find(subject.token_id)

      expect(token.api).to eq('entreprise')
    end

    it 'archives previous token' do
      expect {
        subject
      }.to change { token.reload.archived }.to(true)
    end
  end
end
