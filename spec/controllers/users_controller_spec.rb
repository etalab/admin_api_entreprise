require 'rails_helper'

describe UsersController, type: :controller do
  describe '#index' do
    before { create_list(:user, 5) }

    context 'when requested from an admin' do
      include_context 'admin request'
      before { get :index }

      it 'returns an HTTP code 200' do
        expect(response.code).to eq('200')
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
          created_at: a_kind_of(String),
        }))
      end
    end

    it_behaves_like 'client user unauthorized', :get, :index
  end

  describe '#create' do
    let(:user_params) { attributes_for :user }
    let(:user_params) do
      {
        email: 'user@email.com',
        context: 'very create',
        cgu_agreement_date: '2020-01-07T12:38:45.490Z'
      }
    end

    context 'when requested from an admin' do
      include_context 'admin request'

      it 'calls the operation to create a user' do
        expect(User::Operation::Create)
          .to receive(:call)
          .and_call_original

        post(:create, params: user_params)
      end

      context 'when data is not valid' do
        before do
          # TODO find a way to stub the called operation here
          # This is not a quickwin since mocking a contract error message
          # is not simple.
          user_params[:email] = ''
          post(:create, params: user_params)
        end

        it 'returns code 422' do
          expect(response.code).to eq('422')
        end

        it 'returns errors' do
          expect(response_json).to match(
            errors: {
              email: a_collection_including(kind_of(String))
            })
        end
      end

      context 'when data is valid' do
        # TODO move this into integration specs, here we want to test that the
        # returned HTTP code and payload is valid. This has already been tested
        # in the operation unit tests
        it 'saves the user into the database' do
          expect { post(:create, params: user_params) }
            .to change(User, :count).by(1)
        end

        it 'calls the mailer to send a confirmation email' do
          expect(UserMailer).to receive(:confirm_account_action).and_call_original

          post(:create, params: user_params)
        end

        it 'returns code 201' do
          post(:create, params: user_params)

          expect(response.code).to eq('201')
        end

        it 'returns the created user' do
          post(:create, params: user_params)

          expect(response_json).to match({
            id: a_kind_of(String),
            email: a_kind_of(String),
            context: a_kind_of(String),
            note: '',
            tokens: [],
            contacts: [],
            blacklisted_tokens: []
          })
        end
      end
    end

    it_behaves_like 'client user unauthorized', :post, :create
  end

  describe '#show' do
    let(:user) { create(:user, :with_jwt, :with_blacklisted_jwt) }

    shared_examples 'show user' do
      it 'returns the user data' do
        get :show, params: { id: user.id }

        expect(response_json).to include({
          id: a_kind_of(String),
          email: a_kind_of(String),
          context: a_kind_of(String),
          tokens: a_collection_including(a_kind_of(String)),
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

      context 'show another user' do
        it_behaves_like 'show user'

        it 'shows blacklisted jwt' do
          get :show, params: { id: user.id }

          expect(response_json).to include(
            blacklisted_tokens: a_collection_including(a_kind_of(String))
          )
        end
      end

      it 'also returns the user note attribute' do
        get :show, params: { id: user.id }

        expect(response_json).to include(:note)
      end
    end

    context 'when requested from a client user' do
      let(:user) { UsersFactory.confirmed_user }
      before { fill_request_headers_with_user_jwt(user.id) }

      it 'returns requesting user\'s info' do
        get :show, params: { id: user.id }

        expect(response.code).to eq('200')
      end

      it 'does not return the user note attribute' do
        get :show, params: { id: user.id }

        expect(response_json).to_not include(:note)
      end

      it 'does not return the user blacklisted jwt' do
        get :show, params: { id: user.id }

        expect(response_json).to_not include(:blacklisted_tokens)
      end

      it 'denies access to other users data' do
        another_user = create(:user)
        get :show, params: { id: another_user.id }

        expect(response.code).to eq('403')
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

  describe '#confirm' do
    let(:inactive_user) { UsersFactory.inactive_user }

    context 'when params are valid' do
      let(:confirmation_params) do
        {
          confirmation_token: inactive_user.confirmation_token,
          password: 'validPWD12',
          password_confirmation: 'validPWD12'
        }
      end

      before { post :confirm, params: confirmation_params, as: :json }

      it 'returns 200' do
        expect(response.code).to eq('200')
      end

      it 'returns a session JWT' do
        expect(response_json).to include(access_token: a_kind_of(String))
      end

      it 'confirms the user' do
        user_token = confirmation_params[:confirmation_token]
        confirmed_user = User.find_by(confirmation_token: user_token)

        expect(confirmed_user).to be_confirmed
      end
    end

    context 'when params are invalid' do
     let(:confirmation_params) do
        {
          confirmation_token: 'oups',
          password: 'validPWD12',
          password_confirmation: 'validPWD12'
        }
      end

      before { post :confirm, params: confirmation_params, as: :json }

      it 'returns 422' do
        expect(response.code).to eq '422'
      end

      it 'returns an error' do
        expect(response_json)
          .to eq errors: { confirmation_token: ['confirmation token not found'] }
      end
    end
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
        note: 'Test update'
      }
    end

    subject { put :update, params: user_params }

    context 'when requested from a user' do
      include_context 'user request'
      it_behaves_like 'client user unauthorized', :put, :update, { id: 'random' }

      it 'does not update the user' do
        subject
        user.reload

        expect(user.note).not_to eq('Test update')
      end
    end

    context 'when requested from an admin' do
      include_context 'admin request'

      context 'when params are valid' do
        it 'returns code 200' do
          subject
          expect(response.code).to eq('200')
        end

        it 'updates the user' do
          subject
          user.reload

          expect(user.note).to eq('Test update')
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
      context 'when the user is not confirmed' do
        before do
          inactive_user = UsersFactory.inactive_user
          renewal_params[:email] = inactive_user.email
        end

        it 'returns a HTTP code 422' do
          subject

          expect(response.code).to eq('422')
        end

        it 'returns an error message' do
          subject

          expect(response_json).to match({ errors: { email: ["the account for #{renewal_params[:email]} is inactive and has not be confirmed"] } })
        end
      end

      context 'when the user is confirmed' do
        before do
          user = UsersFactory.confirmed_user
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
  end
end
