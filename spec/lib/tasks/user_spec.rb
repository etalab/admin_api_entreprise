require 'rails_helper'

RSpec.describe 'user tasks', type: :rake do
  include_context 'when using rake mute tasks'

  let(:task_name) { 'user:transfer_account' }

  describe 'user:transfer_account' do
    subject(:run_task) do
      Rake::Task[task_name].invoke(current_owner.email, target_user_email)
    end

    let!(:current_owner) { create(:user, :with_token) }
    let(:target_user_email) { 'new_owner@email.com' }

    it 'transfer account to new user' do
      expect(APIEntreprise::User::TransferAccount).to receive(:call)
        .with(
          hash_including(
            current_owner:,
            target_user_email:
          )
        )
        .and_call_original

      run_task
    end
  end
end
