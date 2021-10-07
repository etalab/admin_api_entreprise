require 'rails_helper'

RSpec.describe 'transfer user account ownership', type: :feature do
  let(:user) { create(:user, :with_jwt) }
  let(:form_dom_id) { '#transfer_account' }
  let(:email) { 'valid@email.com' }

  subject do
    visit user_profile_path
    within form_dom_id do
      fill_in 'email', with: email
      click_button
    end
  end

  before { login_as(user) }

  shared_examples :it_aborts_the_transfer do
    it 'displays an error' do
      subject

      expect(page).to have_css('.alert')
    end

    it 'does not transfer any tokens' do
      user_tokens_id = user.jwt_api_entreprise.pluck(:id)
      subject

      expect(user.jwt_api_entreprise.reload.pluck(:id))
        .to contain_exactly(*user_tokens_id)
    end
  end

  context 'when no email address is provided' do
    let(:email) { '' }

    it_behaves_like :it_aborts_the_transfer
  end

  context 'when the provided email address is invalid' do
    let(:email) { 'not a valid email' }

    it_behaves_like :it_aborts_the_transfer
  end

  context 'when the provided email address is valid' do
    it 'displays success' do
      subject

      expect(page).to have_css('.notice')
    end

    it 'deletes the tokens from the previous account' do
      subject

      expect(user.jwt_api_entreprise).to be_empty
    end

    it 'transfer the tokens to the target account' do
      tokens_id = user.jwt_api_entreprise.pluck(:id)
      subject
      target_user = User.find_by(email: email)

      expect(target_user.jwt_api_entreprise.pluck(:id)).to include(*tokens_id)
    end
  end
end
