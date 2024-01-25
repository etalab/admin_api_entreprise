require 'rails_helper'

RSpec.describe 'transfer user account ownership', :js do
  subject do
    visit api_particulier_user_profile_path

    click_button 'transfer_account_accordion'
    sleep 1
    click_link 'transfer_account_button'

    within form_dom_id do
      fill_in 'email', with: email

      accept_prompt do
        click_button
      end
    end
  end

  let(:user) { create(:user) }
  let(:form_dom_id) { '#transfer_account_form' }
  let(:email) { 'valid@email.com' }

  before { login_as(user) }

  describe 'when on api_particulier', app: :api_particulier do
    let!(:authorization_requests) do
      create_list(:authorization_request, 2, :with_tokens, :with_demandeur, demandeur: user, api: 'particulier')
    end

    context 'when no email address is provided' do
      let(:email) { '' }

      it_behaves_like 'it aborts the user account transfer'
    end

    context 'when the provided email address is valid' do
      it_behaves_like 'it succeeds the user account transfer'
    end
  end

  describe 'when on api_entreprise', app: :api_entreprise do
    let!(:authorization_requests) do
      create_list(:authorization_request, 2, :with_tokens, :with_demandeur, demandeur: user, api: 'entreprise')
    end

    context 'when no email address is provided' do
      let(:email) { '' }

      it_behaves_like 'it aborts the user account transfer'
    end

    context 'when the provided email address is valid' do
      it_behaves_like 'it succeeds the user account transfer'
    end
  end
end
