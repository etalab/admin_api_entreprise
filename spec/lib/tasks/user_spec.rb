require 'rails_helper'

RSpec.describe 'user tasks', type: :rake do
  include_context 'when using rake mute tasks'

  let(:task_name) { 'user:transfer_account' }

  describe 'user:transfer_account' do
    subject(:run_task) do
      Rake::Task[task_name].invoke(current_owner.email, target_user_email, namespace)
    end

    let!(:current_owner) { create(:user) }
    let!(:target_user_email) { 'new_owner@email.com' }

    let!(:namespace) { 'api_entreprise' }
    let!(:authorization_requests) do
      create_list(:authorization_request, 3, :with_tokens, :with_demandeur, demandeur: current_owner, api: 'entreprise')
    end

    it 'transfer account to new user' do
      expect(User::TransferAccount).to receive(:call)
        .with(
          hash_including(
            current_owner:,
            target_user_email:,
            authorization_requests:,
            namespace:
          )
        )
        .and_call_original

      run_task
    end
  end
end
