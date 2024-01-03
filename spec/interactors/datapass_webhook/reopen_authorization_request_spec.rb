# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::ReopenAuthorizationRequest, type: :interactor do
  subject { described_class.call(datapass_webhook_params.merge(authorization_request:)) }

  let(:authorization_request) { create(:authorization_request) }
  let!(:token) { create(:token, authorization_request:) }
  let(:datapass_webhook_params) { build(:datapass_webhook, event:) }
  let(:scopes) { build(:datapass_webhook_pass_model)['scopes'].keys }

  context 'when event is not reopen' do
    let(:event) { 'owner' }

    it { is_expected.to be_a_success }
  end

  context 'when event is reopen' do
    let(:event) { 'reopen' }

    describe 'when there is no current_prolong_token_wizard' do
      it { is_expected.to be_a_success }
    end

    describe 'when there is a current_prolong_token_wizard' do
      let!(:current_prolong_token_wizard) { create(:prolong_token_wizard, token:, status:, owner: 'still_in_charge', project_purpose: true, contact_technique: false, contact_metier: true) }

      describe "when current_prolong_token_wizard's status is nil" do
        let!(:status) { nil }

        it { is_expected.to be_a_success }

        it 'does not change current_prolong_token_wizard status to requires_update' do
          expect(current_prolong_token_wizard.reload.status).to be_nil
        end
      end

      describe "when current_prolong_token_wizard's status is not requires_update" do
        let!(:status) { 'owner' }

        it { is_expected.to be_a_success }

        it 'does not change current_prolong_token_wizard status to requires_update' do
          expect(current_prolong_token_wizard.reload.status).to eq('owner')
        end
      end

      describe "when current_prolong_token_wizard's status is requires_update" do
        let!(:status) { 'requires_update' }

        it { is_expected.to be_a_success }

        it 'changes current_prolong_token_wizard status to requires_update' do
          expect {
            subject
          }.to change { current_prolong_token_wizard.reload.status }.from('requires_update').to('updates_requested')
        end
      end
    end
  end
end
