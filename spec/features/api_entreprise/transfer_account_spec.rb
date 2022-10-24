require 'rails_helper'

RSpec.describe 'transfer user account ownership', app: :api_entreprise, js: true do
  subject do
    visit user_profile_path

    click_on 'transfer_account_button'

    within form_dom_id do
      fill_in 'email', with: email

      accept_prompt do
        click_button
      end
    end
  end

  let(:user) { create(:user, :with_token) }
  let(:form_dom_id) { '#transfer_account' }
  let(:email) { 'valid@email.com' }

  before { login_as(user) }

  shared_examples 'it aborts the transfer' do
    it_behaves_like 'display alert', :error

    it 'does not transfer any tokens' do
      user_tokens_id = user.tokens.pluck(:id)
      subject

      expect(user.tokens.reload.pluck(:id))
        .to contain_exactly(*user_tokens_id)
    end
  end

  context 'when no email address is provided' do
    let(:email) { '' }

    it_behaves_like 'it aborts the user account transfer'
  end

  context 'when the provided email address is valid' do
    it_behaves_like 'it succeeds the user account transfer'
  end
end
