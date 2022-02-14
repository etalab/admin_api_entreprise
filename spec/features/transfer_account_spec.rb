require 'rails_helper'

RSpec.describe 'transfer user account ownership', type: :feature, js: true do
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

  let(:user) { create(:user, :with_jwt) }
  let(:form_dom_id) { '#transfer_account' }
  let(:email) { 'valid@email.com' }

  before { login_as(user) }

  shared_examples 'it aborts the transfer' do
    it_behaves_like 'display alert', :error

    it 'does not transfer any tokens' do
      user_tokens_id = user.jwt_api_entreprise.pluck(:id)
      subject

      expect(user.jwt_api_entreprise.reload.pluck(:id))
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

  describe 'transfering another user account', js: false do
    subject do
      page.driver.post(user_transfer_account_index_path(user_id: another_user.id), params: {
        email: 'hackerman@email.fr'
      })
    end

    let(:another_user) { create(:user) }

    it 'does not transfer any tokens' do
      user_tokens_id = user.jwt_api_entreprise.pluck(:id)
      subject

      expect(user.jwt_api_entreprise.reload.pluck(:id))
        .to contain_exactly(*user_tokens_id)
    end

    it 'returns an error' do
      subject

      expect(page.driver.status_code).to eq(403)
    end
  end
end
