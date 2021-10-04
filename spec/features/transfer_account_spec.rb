require 'rails_helper'

RSpec.describe 'transfer user account ownership', type: :feature do
  let(:user) { create(:user, :with_jwt) }
  let(:form_dom_id) { "#transfer_account_user_#{user.id}" }
  let(:email) { 'valid@email.com' }

  subject do
    visit user_profile_path
    within form_dom_id do
      fill_in 'email', with: email
      click_button 'Confirmer'
    end
  end

  before { log_as(user) }

  it 'calls the underlying operation' do
    expect(User::Operation::TransferOwnership)
      .to receive(:call)
      .with(params: { id: user.id, email: email })
      .and_call_original

    subject
  end

  context 'when no email address is provided' do
    let(:email) { '' }

    it 'returns an error' do
      subject

      expect(page).to have_css('.alert')
    end
  end

  context 'when the provided email address is invalid' do
    let(:email) { 'not a valid email' }

    it 'returns an error' do
      subject

      expect(page).to have_css('.alert')
    end
  end

  context 'when the provided email address is valid' do
    it 'works' do
      subject

      expect(page).to have_css('.notice')
    end
  end
end
