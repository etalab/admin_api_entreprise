require 'rails_helper'

RSpec.describe API::UsersController, type: :controller do
  describe '#index' do
    before { create_list(:user, 5) }

    context 'when requested from an admin' do
      include_context 'admin request'

      context 'when requested without filters' do
        before { get :index }

        it 'returns an HTTP code 200' do
          expect(response.code).to eq('200')
        end

        it 'calls User::Operation::Index' do
          expect(User::Operation::Index).to receive(:call)
            .and_call_original

          get :index
        end

        it 'returns all users from database' do
          # Pretty ugly... We have one more user than the 5 created: the admin
          expect(response_json.size).to eq(6)
        end

        it 'returns the correct payload format' do
          expect(response_json).to all(match({
            id: a_kind_of(String),
            email: a_kind_of(String),
            context: a_kind_of(String),
            confirmed: be(true).or(be(false)),
            oauth_api_gouv_id: a_kind_of(String),
            created_at: a_kind_of(String),
          }))
        end
      end

      context 'when requested with filters' do
        it 'apply filters' do
          User.take.update(email: 'random_query')
          get :index, params: { email: 'random_query' }, as: :json

          expect(response_json).to contain_exactly(
            a_hash_including(email: 'random_query')
          )
        end
      end
    end

    it_behaves_like 'client user unauthorized', :get, :index
  end

  describe '#show' do
    before do
      user.jwt_api_entreprise.find_each do |jwt|
        create_list(:role, 4, jwt_api_entreprise: [jwt])
      end
    end

    let(:user) do
      create(:user,
             :with_jwt,
             :with_blacklisted_jwt,
             :with_archived_jwt,
             :with_expired_jwt
            )
    end

    let(:blacklisted_jwt) { user.jwt_api_entreprise.where(blacklisted: true).first }
    let(:archived_jwt) { user.jwt_api_entreprise.where(archived: true).first }
    let(:expired_jwt) { user.jwt_api_entreprise.where('exp < ?', Time.zone.now.to_i) }

    shared_examples 'show user' do
      it 'returns the user data' do
        get :show, params: { id: user.id }

        expect(response_json).to include({
          id: a_kind_of(String),
          email: a_kind_of(String),
          context: a_kind_of(String),
          oauth_api_gouv_id: a_kind_of(String),
          tokens: a_collection_including(
            a_hash_including({
              id: String,
              authorization_request_id: String,
              secret_key: String,
              iat: Integer,
              exp: Integer,
              subject: String,
              roles: a_collection_including(String),
              archived: be(true).or(be(false)),
              blacklisted: be(true).or(be(false))
            })
          ),
          contacts: a_collection_including(
            a_hash_including(
              jwt_usage_policy: a_kind_of(String),
              jwt_id: a_kind_of(String),
              id: a_kind_of(String),
              email: a_kind_of(String),
              phone_number: a_kind_of(String),
              contact_type: a_kind_of(String)
            )
          )
        })
      end
    end

    context 'when requested from an admin' do
      include_context 'admin request'

      context 'when user does not exist' do
        it 'returns 404' do
          get :show, params: { id: 0 }

          expect(response.code).to eq('404')
        end
      end

      context 'when user exists' do
        it_behaves_like 'show user'

        it 'shows blacklisted jwt' do
          get :show, params: { id: user.id }

          expect(response_json).to include(
            tokens: a_collection_including(a_hash_including({
              blacklisted: true
            }))
          )
        end

        it 'shows archived jwt' do
          get :show, params: { id: user.id }

          expect(response_json).to include(
            tokens: a_collection_including(a_hash_including({
              archived: true
            }))
          )
        end

        it 'returns the user note attribute' do
          get :show, params: { id: user.id }

          expect(response_json).to include(:note)
        end

        it 'shows contacts of archived JWT' do
          get :show, params: { id: user.id }

          expect(response_json).to include(
            contacts: a_collection_including(a_hash_including({
              jwt_id: archived_jwt.id
            }))
          )
        end

        it 'shows contacts of blacklisted JWT' do
          get :show, params: { id: user.id }

          expect(response_json).to include(
            contacts: a_collection_including(a_hash_including({
              jwt_id: blacklisted_jwt.id
            }))
          )
        end

        it 'returns the user\'s expired tokens' do
          get :show, params: { id: user.id }
          tokens_in_payload = response_json[:tokens]
          tokens_ids_in_payload = tokens_in_payload.map! { |t| t[:id] }

          expect(tokens_ids_in_payload).to include(*expired_jwt.ids)
        end

        context 'when user does not have jwt token' do
          before do
            user.jwt_api_entreprise.each do |token|
              token.destroy
            end
          end

          it 'renders 200 (non regression test)' do
            get :show, params: { id: user.id }

            expect(response.status).to eq(200)
          end
        end
      end
    end

    context 'when requested from a client user' do
      before { fill_request_headers_with_user_jwt(user.id) }

      it_behaves_like 'show user'

      it 'responds with an HTTP code 200' do
        get :show, params: { id: user.id }

        expect(response.code).to eq('200')
      end

      it 'does not return the user note attribute' do
        get :show, params: { id: user.id }

        expect(response_json).to_not include(:note)
      end

      it 'does not return the user blacklisted jwt' do
        get :show, params: { id: user.id }

        expect(response_json[:tokens]).to all(include(blacklisted: false))
      end

      it 'does not return the user archived jwt' do
        get :show, params: { id: user.id }

        expect(response_json[:tokens]).to all(include(archived: false))
      end

      it 'does not return the user\'s expired tokens' do
        get :show, params: { id: user.id }
        tokens_in_payload = response_json[:tokens]
        tokens_ids_in_payload = tokens_in_payload.map! { |t| t[:id] }

        expect(tokens_ids_in_payload).to_not include(*expired_jwt.ids)
      end

      it 'denies access to other users data' do
        another_user = create(:user)
        get :show, params: { id: another_user.id }

        expect(response.code).to eq('403')
      end

      describe 'associated contacts' do
        it 'does not return contacts for an archived token' do
          get :show, params: { id: user.id }

          expect(response_json[:contacts]).to_not include(a_hash_including(jwt_id: archived_jwt.id))
        end

        it 'does not return contacts for a blacklisted token' do
          get :show, params: { id: user.id }

          expect(response_json[:contacts]).to_not include(a_hash_including(jwt_id: blacklisted_jwt.id))
        end
      end
    end
  end

  describe '#destroy' do
    context 'when requested from an admin' do
      include_context 'admin request'

      context 'when user does not exist' do
        it 'returns 404' do
          delete :destroy, params: { id: 0 }

          expect(response.code).to eq('404')
        end

        it 'does not change the database' do
          expect { delete :destroy, params: { id: 0 } }
            .to_not change(User, :count)
        end
      end

      context 'when user exists' do
        it 'returns 204' do
          user = create(:user)
          delete :destroy, params: { id: user.id }

          expect(response.code).to eq('204')
        end

        it 'deletes the user' do
          user = create(:user)
          expect { delete :destroy, params: { id: user.id } }
            .to change(User, :count).by(-1)
        end

        pending 'it deletes associated tokens'
      end
    end

    it_behaves_like 'client user unauthorized', :delete, :destroy, { id: 0 }
  end

  describe '#password_reset' do
    let(:user) { create(:user, pwd_renewal_token: 'verytoken', pwd_renewal_token_sent_at: 12.hours.ago) }
    let(:pwd_reset_params) do
      {
        token: user.pwd_renewal_token,
        password: 'Coucou123!',
        password_confirmation: 'Coucou123!'
      }
    end

    context 'when params are valid' do
      before { post :password_reset, params: pwd_reset_params }

      it 'returns an HTTP code 200' do
        expect(response.code).to eq('200')
      end

      it 'returns a JWT token for the user to be logged in' do
        expect(response_json).to include(access_token: a_kind_of(String))
      end
    end

    context 'when params are invalid' do
      before do
        pwd_reset_params.delete(:token)
        post :password_reset, params: pwd_reset_params
      end

      it 'returns a HTTP code 422' do
        expect(response.code).to eq('422')
      end

      it 'returns an error message' do
        expect(response_json).to match({ errors: { token: ['is missing']}})
      end
    end
  end

  describe '#update' do
    let(:user) { create(:user) }
    let(:user_params) do
      {
        id: user.id,
        note: 'Test update',
        oauth_api_gouv_id: '9001'
      }
    end

    subject(:update_user!) { put :update, params: user_params, as: :json }

    context 'when requested from a user' do
      include_context 'user request'
      it_behaves_like 'client user unauthorized', :put, :update, { id: 'random' }

      it 'does not update the user' do
        update_user!
        user.reload

        expect(user.note).not_to eq('Test update')
      end
    end

    context 'when requested from an admin' do
      include_context 'admin request'

      context 'when params are valid' do
        it 'returns code 200' do
          update_user!

          expect(response.code).to eq('200')
        end

        it 'updates the user' do
          update_user!
          user.reload

          expect(user).to have_attributes({
            note: 'Test update',
            oauth_api_gouv_id: '9001'
          })
        end
      end
    end
  end

  describe '#password_renewal' do
    let(:renewal_params) { { email: 'test_email' } }

    subject { post :password_renewal, params: renewal_params }

    context 'when the :email params is not present' do
      before { renewal_params[:email] = nil }

      it 'returns a HTTP code 422' do
        subject

        expect(response.code).to eq('422')
      end

      it 'returns an error message' do
        subject

        expect(response_json).to match({ errors: { email: ['must be filled'] } })
      end
    end

    context 'when the email does not identify any user' do
      it 'returns a HTTP code 422' do
        subject

        expect(response.code).to eq('422')
      end

      it 'returns an error message' do
        subject

        expect(response_json).to match({ errors: { email: ['user with email "test_email" does not exist'] } })
      end
    end

    context 'when the user exists' do
      before do
        user = create(:user)
        renewal_params[:email] = user.email
      end

      it 'returns a HTTP code 200' do
        subject

        expect(response.code).to eq('200')
      end

      it 'returns an empty payload' do
        subject

        expect(response_json).to eq({})
      end

      it 'sends an email' do
        expect(UserMailer).to receive(:renew_account_password).and_call_original

        subject
      end
    end
  end

  describe '#transfer_ownership' do
    let(:old_owner) { create(:user, :with_jwt) }
    let(:new_owner_email) { 'yours@is.mine' }

    subject(:call!) do
      post :transfer_ownership, params: { id: old_owner.id, email: new_owner_email }
    end

    shared_examples :account_transfer_success do
      context 'when the email address is valid' do
        it 'returns HTTP code 200' do
          call!

          expect(response.status).to eq(200)
        end

        it 'returns the current user payload without any JWT' do
          call!

          expect(response_json).to include({
            id: old_owner.id,
            email: old_owner.email,
            context: old_owner.context,
            oauth_api_gouv_id: old_owner.oauth_api_gouv_id,
            contacts: [],
            tokens: []
          })
        end

        it 'calls the underlying operation' do
          expect(User::Operation::TransferOwnership).to receive(:call).and_call_original

          call!
        end
      end

      context 'when the email address is not valid' do
        let(:new_owner_email) { 'badFormatN00b' }

        it 'returns HTTP code 422' do
          call!

          expect(response.status).to eq(422)
        end

        it 'returns an error message' do
          call!

          expect(response_json).to match({
            errors: { email: ['is in invalid format'] }
          })
        end
      end
    end

    context 'when requested from an admin' do
      include_context 'admin request'

      it_behaves_like :account_transfer_success
    end

    context 'when requested from the current owner' do
      before do
        fill_request_headers_with_user_jwt(old_owner.id)
      end

      it_behaves_like :account_transfer_success
    end

    context 'when requested from a user who do not own the account' do
      include_context 'user request'

      before { call! }

      it 'returns HTTP code 403' do
        expect(response.status).to eq(403)
      end

      it 'returns an error message' do
        expect(response_json).to match({
          errors: 'Forbidden'
        })
      end
    end
  end
end
