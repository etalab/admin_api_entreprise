RSpec.shared_examples 'a signin process via magic link' do
  include ActiveJob::TestHelper
  let(:email) { 'any-email@lol.com' }

  describe 'when asking for a magic link' do
    subject do
      visit login_path
      fill_in 'email', with: email
      click_on 'send_magic_link'
    end

    context 'when the email is not from a User or a Contact' do
      it_behaves_like 'it aborts magic link'
    end

    context 'when the email is from a User' do
      let!(:user) { create(:user, email:) }

      it_behaves_like 'it creates a magic link'
      it_behaves_like 'it sends a magic link for signin'
      it_behaves_like 'it displays a magic-link-sent confirmation and redirects'
    end

    context 'when the email is from a Contact' do
      let!(:contact) { create(:contact, email:, token: create(:token)) }

      it_behaves_like 'it creates a magic link'
      it_behaves_like 'it sends a magic link for tokens'
      it_behaves_like 'it displays a magic-link-sent confirmation and redirects'
    end
  end

  describe 'when using a magic link' do
    let(:mail) { ActionMailer::Base.deliveries.last }
    let(:mail_parsed) { Nokogiri::HTML(mail.html_part.body.to_s) }
    let(:target_url) { mail_parsed.at("a:contains('suivant')")['href'] }

    let(:access_token) { MagicLink.find_by(email:).access_token }

    context 'when the magic link is valid' do
      subject do
        visit login_path
        fill_in 'email', with: email
        click_on 'send_magic_link'

        perform_enqueued_jobs

        visit target_url
      end

      context 'when the email is from a User' do
        let!(:user) { create(:user, email:) }

        it 'redirects to the user profile' do
          subject

          expect(page).to have_current_path(user_profile_path, ignore_query: true)
        end
      end

      context 'when the email is from a Contact' do
        let!(:contact) { create(:contact, email:, token: create(:token)) }

        describe 'when the user logins with the magic link' do
          it 'login to the token list page' do
            subject

            expect(page).to have_current_path(token_show_magic_link_path(access_token:))
          end
        end
      end
    end

    context 'when the magic link is expired' do
      subject do
        visit login_path
        fill_in 'email', with: email
        click_on 'send_magic_link'

        perform_enqueued_jobs

        Timecop.travel(1.year.from_now) { visit target_url }
      end

      context 'when the email is from a User' do
        let!(:user) { create(:user, email:) }

        it 'redirects to the login page' do
          subject

          expect(page).to have_current_path(login_path, ignore_query: true)
        end

        it_behaves_like 'display alert', :error
      end

      context 'when the email is from a Contact' do
        let!(:contact) { create(:contact, email:, token: create(:token)) }

        it 'redirects to the login page' do
          subject

          expect(page).to have_current_path(login_path, ignore_query: true)
        end

        it_behaves_like 'display alert', :error
      end
    end
  end
end
