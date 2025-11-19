require 'rails_helper'

RSpec.shared_examples 'a token magic link creation feature' do |options = {}|
  mailer_class = options[:mailer_class] # rubocop:disable RSpec/LeakyLocalVariable

  subject do
    visit send(token_transfer_path_helper, token)
    within("##{dom_id(token, :magic_link)}") do
      fill_in 'email', with: email
      click_button
    end
  end

  let(:token_transfer_path_helper) { options[:token_transfer_path_helper] || :token_transfer_path }
  let(:token_create_magic_link_path_helper) { options[:token_create_magic_link_path_helper] || :token_create_magic_link_path }
  let(:login_path_helper) { options[:login_path_helper] || :login_path }
  let(:authorization_requests_path_helper) { options[:authorization_requests_path_helper] || :authorization_requests_path }
  let(:authorization_request_path_helper) { options[:authorization_request_path_helper] || :authorization_request_path }
  let(:api) { options[:api] }

  let(:user) { create(:user) }
  let(:authorization_request) do
    if api
      create(:authorization_request, :with_tokens, :with_demandeur, :validated, demandeur: user, api: api)
    else
      create(:authorization_request, :with_tokens, :with_demandeur, :validated, demandeur: user)
    end
  end
  let(:token) { authorization_request.token }
  let(:new_magic_link) { MagicLink.find_by(email:) }

  context 'when the user is not logged in' do
    it 'redirects to the login page' do
      visit send(token_transfer_path_helper, token)

      expect(page).to have_current_path(send(login_path_helper), ignore_query: true)
    end
  end

  context 'when the user is logged in' do
    context 'when the current user is the token owner' do
      before { login_as(user) }

      context 'when the email address is valid' do
        let(:email) { 'valid@email.com' }

        describe 'with javascript actived', :js do
          it 'from authorization_request page, displays modal on click' do
            visit send(authorization_request_path_helper, authorization_request)
            click_link 'show-token-modal-link'
            click_link dom_id(token, :transfer_modal_button)
            expect(page).to have_button(I18n.t('shared.transfer_tokens.new.modal.transfer.cta'))
          end
        end

        it_behaves_like 'it creates a magic link'

        it 'redirects to the user authorization_request index page' do
          subject

          expect(page).to have_current_path(send(authorization_requests_path_helper))
        end

        it 'saves the token_id in the magic link' do
          subject

          expect(new_magic_link.token).to eq(token)
        end
      end

      context 'when the email address is invalid' do
        let(:email) { 'not an email' }

        it_behaves_like 'it aborts magic link', mailer_class
        it_behaves_like 'display alert', :error
      end
    end

    context 'when the current user is not the token owner' do
      subject do
        page.driver.post(send(token_create_magic_link_path_helper, token), params: {
          email: 'much@hack.ack'
        })
      end

      before { login_as(create(:user)) }

      let(:user) { create(:user) }
      let(:email) { 'valid@email.com' }

      it_behaves_like 'it aborts magic link', mailer_class

      it 'returns an error' do
        subject

        expect(page.driver.status_code).to eq(403)
      end
    end
  end
end
