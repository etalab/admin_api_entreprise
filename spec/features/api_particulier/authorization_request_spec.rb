RSpec.describe 'displays authorization requests', app: :api_particulier do
  subject(:go_to_authorization_requests_show) do
    visit api_particulier_authorization_requests_show_path(id: authorization_request.id)
  end

  let!(:authenticated_user) { create(:user, :demandeur) }
  let!(:non_authenticated_user) { create(:user, :demandeur) }
  let!(:authorization_request) do
    create(
      :authorization_request,
      demandeur_authorization_request_role: non_authenticated_user.user_authorization_request_roles.first,
      api: 'entreprise'
    )
  end

  let!(:access_logs) do
    [
      create(:access_log, token:, timestamp: 1.day.ago),
      create(:access_log, token:, timestamp: 2.days.ago),
      create(:access_log, token:, timestamp: 3.days.ago),
      create(:access_log, token:, timestamp: 4.days.ago),
      create(:access_log, token:, timestamp: 8.days.ago)
    ]
  end

  let!(:token) do
    create(:token, authorization_request:, exp:, blacklisted_at:)
  end

  let!(:banned_token) { create(:token, authorization_request:, exp:, blacklisted_at: 1.day.from_now) }

  let(:exp) { 1.day.from_now.to_i }
  let(:blacklisted_at) { nil }

  describe 'when user is not authenticated' do
    it 'redirects to the login' do
      go_to_authorization_requests_show
      expect(page).to have_current_path(api_particulier_login_path, ignore_query: true)
    end
  end

  describe 'when user is authenticated' do
    before do
      login_as(authenticated_user)
      go_to_authorization_requests_show
    end

    describe 'when authorization_request does not belong to current_user' do
      it 'redirects to the profile' do
        expect(page).to have_current_path(api_particulier_user_profile_path, ignore_query: true)
      end
    end

    describe 'when authorization_request belongs to current_user' do
      describe 'when it not viewable by users' do
        let!(:authorization_request) do
          create(
            :authorization_request,
            demandeur_authorization_request_role: authenticated_user.user_authorization_request_roles.first,
            api: 'entreprise',
            status: 'draft'
          )
        end

        it 'redirects to the profile' do
          expect(page).to have_current_path(api_particulier_user_profile_path, ignore_query: true)
        end
      end

      describe 'when authorization_request is from api_entreprise' do
        let!(:authorization_request) do
          create(
            :authorization_request,
            demandeur_authorization_request_role: authenticated_user.user_authorization_request_roles.first,
            api: 'entreprise',
            status: 'validated'
          )
        end

        it 'redirects to the profile' do
          expect(page).to have_current_path(api_particulier_user_profile_path, ignore_query: true)
        end
      end

      describe 'when authorization_request is from api_particulier' do
        let!(:authorization_request) do
          create(
            :authorization_request,
            demandeur_authorization_request_role: authenticated_user.user_authorization_request_roles.first,
            api: 'particulier',
            status:
          )
        end

        describe 'when the authorization request is not viewable by user' do
          let(:status) { 'draft' }

          it 'redirects to the profile' do
            expect(page).to have_current_path(api_particulier_user_profile_path, ignore_query: true)
          end
        end

        describe 'when the authorization request is validated' do
          let(:status) { 'validated' }

          it 'diplays basic information on the page' do
            expect(page).to have_current_path(api_particulier_authorization_requests_show_path(id: authorization_request.id), ignore_query: true)
            expect(page).to have_content('Habilitation active')
            expect(page).to have_link(href: datapass_authorization_request_url(authorization_request))
            expect(page).to have_content(friendly_format_from_timestamp(authorization_request.created_at))

            expect(page).to have_content('Jeton principal :')
            expect(page).to have_content('Actif')
            expect(page).to have_content(token.id)
            expect(page).to have_content('4 appels les 7 derniers jours')
            expect(page).to have_content(distance_of_time_in_words(Time.zone.now, token.exp))

            expect(page).to have_content(banned_token.id)
            expect(page).to have_content('Banni')
            expect(page).to have_content(distance_of_time_in_words(Time.zone.now, banned_token.blacklisted_at))
            expect(page).to have_content('0 appel les 7 derniers jours')
          end

          describe 'when the user is demandeur' do
            describe 'when the token has less than 90 days left' do
              it 'displays the button to extend the token' do
                expect(page).to have_content('Prolonger le jeton')
              end

              it 'displays the modal on click' do
                click_button dom_id(token, :extend_modal_button)
                expect(page).to have_css("##{dom_id(token, :extend_modal)}")
              end
            end

            describe 'when the token has more than 90 days left' do
              let(:exp) { 93.days.from_now.to_i }

              it 'does not display the button to extend the token' do
                expect(page).not_to have_content('Prolonger le jeton')
              end
            end
          end

          describe 'when the user is contact technique' do
            let!(:authorization_request) do
              create(
                :authorization_request,
                demandeur_authorization_request_role: non_authenticated_user.user_authorization_request_roles.first,
                contact_technique_authorization_request_role: authenticated_user.user_authorization_request_roles.first,
                api: 'particulier',
                status:
              )
            end

            it 'does not display the button to extend the token' do
              expect(page).not_to have_content('Prolonger le jeton')
            end
          end

          describe 'when the user is contact metier' do
            let!(:authorization_request) do
              create(
                :authorization_request,
                demandeur_authorization_request_role: non_authenticated_user.user_authorization_request_roles.first,
                contact_metier_authorization_request_role: authenticated_user.user_authorization_request_roles.first,
                api: 'particulier',
                status:
              )
            end

            it 'does not display the button to extend the token' do
              expect(page).not_to have_content('Prolonger le jeton')
            end
          end
        end
      end
    end
  end
end
