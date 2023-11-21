RSpec.describe 'displays show of authorization request', app: :api_particulier do
  subject(:go_to_authorization_request) do
    visit api_particulier_authorization_request_path(id: authorization_request.id)
  end

  let!(:authenticated_user) { create(:user, :demandeur, :contact_technique, :contact_metier) }
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
    create(:token, authorization_request:, exp:, blacklisted_at:, scopes:)
  end

  let!(:old_tokens) do
    [
      create(:token, authorization_request:, exp: 1.day.ago, blacklisted_at: 1.day.from_now, scopes:),
      create(:token, authorization_request:, exp: 1.day.from_now, blacklisted_at: 1.day.ago, scopes:),
      create(:token, authorization_request:, exp: 1.day.ago, blacklisted_at: 1.day.ago, scopes:)
    ]
  end

  let!(:scopes) { [] }

  let!(:banned_token) { create(:token, authorization_request:, exp:, blacklisted_at: 1.day.from_now) }

  let(:exp) { 1.day.from_now.to_i }
  let(:blacklisted_at) { nil }

  describe 'when user is not authenticated' do
    it 'redirects to the login' do
      go_to_authorization_request
      expect(page).to have_current_path(api_particulier_login_path, ignore_query: true)
    end
  end

  describe 'when user is authenticated' do
    before do
      login_as(authenticated_user)
      go_to_authorization_request
    end

    describe 'when authorization_request does not belong to current_user' do
      it 'redirects to the profile' do
        expect(page).to have_current_path(api_particulier_authorization_requests_path, ignore_query: true)
      end
    end

    describe 'when authorization_request belongs to current_user' do
      describe 'when it not viewable by users' do
        let!(:authorization_request) do
          create(
            :authorization_request,
            :with_demandeur,
            demandeur: authenticated_user,
            api: 'entreprise',
            status: 'draft'
          )
        end

        it 'redirects to the profile' do
          expect(page).to have_current_path(api_particulier_authorization_requests_path, ignore_query: true)
        end
      end

      describe 'when authorization_request is from api_entreprise' do
        let!(:authorization_request) do
          create(
            :authorization_request,
            :with_demandeur,
            demandeur: authenticated_user,
            api: 'entreprise',
            status: 'validated'
          )
        end

        it 'redirects to the profile' do
          expect(page).to have_current_path(api_particulier_authorization_requests_path, ignore_query: true)
        end
      end

      describe 'when authorization_request is from api_particulier' do
        let!(:authorization_request) do
          create(
            :authorization_request,
            :with_demandeur,
            demandeur: authenticated_user,
            api: 'particulier',
            status:
          )
        end

        describe 'when the authorization request is not viewable by user' do
          let(:status) { 'draft' }

          it 'redirects to the profile' do
            expect(page).to have_current_path(api_particulier_authorization_requests_path, ignore_query: true)
          end
        end

        describe 'when the authorization request is validated' do
          let(:status) { 'validated' }

          it 'diplays basic information on the page' do
            expect(page).to have_current_path(api_particulier_authorization_request_path(id: authorization_request.id), ignore_query: true)
            expect(page).to have_content('Habilitation active')
            expect(page).to have_link(href: datapass_authorization_request_url(authorization_request))
            expect(page).to have_content(friendly_format_from_timestamp(authorization_request.created_at))

            expect(page).to have_content('Jeton principal :')
            expect(page).to have_content('Actif')
            expect(page).to have_content(token.id)
            expect(page).to have_content('4 appels les 7 derniers jours')
            expect(page).to have_content(distance_of_time_in_words(Time.zone.now, token.exp))

            expect(page).to have_css('#' << dom_id(token, :stats_link))

            expect(page).to have_content(banned_token.id)
            expect(page).to have_content('Banni')
            expect(page).to have_content(distance_of_time_in_words(Time.zone.now, banned_token.blacklisted_at))
            expect(page).to have_content('0 appel les 7 derniers jours')
          end

          describe 'when the user is demandeur' do
            describe 'when the token has less than 90 days left' do
              it 'displays the button to prolong the token' do
                expect(page).not_to have_css('#prolong-token-modal-link')
              end
            end

            describe 'when the token has more than 90 days left' do
              let(:exp) { 93.days.from_now.to_i }

              it 'does not display the button to prolong the token' do
                expect(page).not_to have_css('#prolong-token-modal-link')
              end
            end

            it 'displays the show token modal button' do
              expect(page).to have_css('#show-token-modal-link')

              click_link 'show-token-modal-link'

              expect(page).to have_content('Utiliser le jeton')
              expect(page).to have_content("Jeton d'accès")
            end

            it 'does not displays the ask for prolongation modal button' do
              expect(page).not_to have_css('#ask-for-prolongation-token-modal-link')
            end

            describe 'when the token has no attestations scopes' do
              it 'does not display the attestations block' do
                expect(page).not_to have_css('#attestations_sociales_et_fiscales')
              end
            end

            describe 'when the token has attestations scopes' do
              let!(:scopes) { %w[attestations_sociales attestations_fiscales] }

              it 'displays the attestations block' do
                expect(page).to have_css('#attestations_sociales_et_fiscales')
                expect(page).to have_css('#attestations_sociales_et_fiscales_link')
              end
            end

            it 'displays the contact informations' do
              expect(page).to have_css('#contact_demandeur')
              expect(page).to have_css('#contact_demandeur_its_me')
              expect(page).not_to have_css('#contact_metier')
              expect(page).not_to have_css('#contact_technique')
            end

            it 'displays the summary' do
              expect(page).to have_css('#summary')
              expect(page).to have_css('#habilitation_main_token_infos_link')
              expect(page).to have_css('#habilitation_contacts_infos_link')
              expect(page).not_to have_css('#attestations_sociales_et_fiscales_link')
            end
          end

          describe 'when the user is contact technique' do
            let!(:authorization_request) do
              create(
                :authorization_request,
                :with_demandeur,
                :with_contact_technique,
                demandeur: non_authenticated_user,
                contact_technique: authenticated_user,
                api: 'particulier',
                status:
              )
            end

            it 'displays the page' do
              expect(page).to have_current_path(api_particulier_authorization_request_path(id: authorization_request.id), ignore_query: true)
            end

            it 'does not display the button to prolong the token' do
              expect(page).not_to have_css('#prolong-token-modal-link')
            end

            it 'displays the show modal button' do
              expect(page).to have_css('#show-token-modal-link')

              click_link 'show-token-modal-link'

              expect(page).to have_content('Utiliser le jeton')
              expect(page).to have_content("Jeton d'accès")
            end

            it 'displays the ask for prolongation modal button' do
              expect(page).to have_css('#ask-for-prolongation-token-modal-link')

              click_link 'ask-for-prolongation-token-modal-link'

              expect(page).to have_content('Relancer le contact principal')
            end

            describe 'when the token has no attestations scopes' do
              it 'does not display the attestations block' do
                expect(page).not_to have_css('#attestations_sociales_et_fiscales')
              end
            end

            describe 'when the token has attestations scopes' do
              let!(:scopes) { %w[attestations_sociales attestations_fiscales] }

              it 'does not display the attestations block' do
                expect(page).not_to have_css('#attestations_sociales_et_fiscales')
              end
            end

            it 'displays the contact informations' do
              expect(page).to have_css('#contact_demandeur')
              expect(page).not_to have_css('#contact_demandeur_its_me')
              expect(page).not_to have_css('#contact_metier')
              expect(page).to have_css('#contact_technique')
              expect(page).to have_css('#contact_technique_its_me')
            end

            it 'displays old tokens accordion' do
              expect(page).to have_css('#old_tokens_accordion_button')

              old_tokens.each do |old_token|
                expect(page).to have_css('#' << dom_id(old_token))
              end

              expect(page).not_to have_css('#' << dom_id(token))
            end
          end

          describe 'when the user is contact metier' do
            let!(:authorization_request) do
              create(
                :authorization_request,
                :with_demandeur,
                :with_contact_technique,
                :with_contact_metier,
                demandeur: non_authenticated_user,
                contact_metier: authenticated_user,
                contact_technique: non_authenticated_user,
                api: 'particulier',
                status:
              )
            end

            it 'displays the page' do
              expect(page).to have_current_path(api_particulier_authorization_request_path(id: authorization_request.id), ignore_query: true)
            end

            it 'does not display the button to prolong the token' do
              expect(page).not_to have_css('#prolong-token-modal-link')
            end

            it 'displays the show modal button' do
              expect(page).to have_css('#show-token-modal-link')

              click_link 'show-token-modal-link'

              expect(page).to have_content('Utiliser le jeton')
              expect(page).to have_content('Contact principal')
            end

            it 'displays the ask for prolongation modal button' do
              expect(page).to have_css('#ask-for-prolongation-token-modal-link')

              click_link 'ask-for-prolongation-token-modal-link'

              expect(page).to have_content('Relancer le contact principal')
            end

            describe 'when the token has no attestations scopes' do
              it 'does not display the attestations block' do
                expect(page).not_to have_css('#attestations_sociales_et_fiscales')
              end
            end

            describe 'when the token has attestations scopes' do
              let!(:scopes) { %w[attestations_sociales attestations_fiscales] }

              it 'displays the attestations block' do
                expect(page).to have_css('#attestations_sociales_et_fiscales')
              end
            end

            it 'displays the contact informations' do
              expect(page).to have_css('#contact_demandeur')
              expect(page).not_to have_css('#contact_demandeur_its_me')
              expect(page).to have_css('#contact_metier')
              expect(page).to have_css('#contact_metier_its_me')
              expect(page).to have_css('#contact_technique')
              expect(page).not_to have_css('#contact_technique_its_me')
            end
          end
        end
      end
    end
  end
end
