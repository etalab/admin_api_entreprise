require 'rails_helper'

describe UsersController, type: :controller do
  describe '#index' do
    # TODO pagination handling
    let(:nb_users) { 10 }
    before do
      create_list :user, nb_users
    end

    context 'when requested from an admin' do
      include_context 'admin request'

      it 'returns all users from database' do
        get :index
        body = JSON.parse(response.body, symbolize_names: true)

        expect(body.size).to eq(11) # admin user is created by admin context inclusion
        expect(response.code).to eq '200'
      end

      it 'returns the correct payload format' do
        get :index
        body = JSON.parse(response.body, symbolize_names: true)
        expect(body).to be_an_instance_of Array

        user_raw = body.first
        expect(user_raw).to be_an_instance_of Hash
        expect(user_raw.size).to eq 4
        expect(user_raw.key?(:id)).to be true
        expect(user_raw.key?(:email)).to be true
        expect(user_raw.key?(:context)).to be true
        expect(user_raw.key?(:confirmed)).to be true
      end
    end

    it_behaves_like 'client user unauthorized', :get, :index
  end

  describe '#create' do
    # getting attributes from :user Factory
    let(:user_params) { attributes_for :user }

    context 'when requested from an admin' do
      include_context 'admin request'

      context 'when data is not valid' do
        before do
          user_params[:email] = ''
          post :create, params: user_params
        end

        it 'returns code 422' do
          expect(response.code).to eq '422'
        end

        it 'returns errors' do
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to be_an_instance_of Hash
        end
      end

      context 'when data is valid' do
        it 'saves the user into the database' do
          expect { post :create, params: user_params }
            .to change(User, :count).by 1
        end

        it 'sends a confirmation email' do
          expect { post :create, params: user_params }
            .to change(ActionMailer::Base.deliveries, :count).by(1)
        end

        context 'when submitting data for contacts creation' do
          let(:params_with_contacts) do
            user_params[:contacts] = []
            user_params[:contacts]
              .append(attributes_for(:contact, contact_type: 'admin'))
              .append(attributes_for(:contact, contact_type: 'tech'))
              .append(attributes_for(:contact, contact_type: 'other'))
            user_params
          end

          it 'returns code 201' do
            post :create, params: user_params
            expect(response.code).to eq '201'
          end

          context 'when submitting data for contacts creation' do
            let(:params_with_contacts) do
              user_params[:contacts] = []
              user_params[:contacts]
                .append(attributes_for(:contact, contact_type: 'admin'))
                .append(attributes_for(:contact, contact_type: 'tech'))
                .append(attributes_for(:contact, contact_type: 'other'))
              user_params
            end

            it 'creates the contacts' do
              expect { post :create, params: params_with_contacts }
                .to change(Contact, :count).by(3)
            end

            it 'associates the created contacts to the user' do
              post :create, params: params_with_contacts
              created_user = User.last
              created_contacts = Contact.last(params_with_contacts[:contacts].size)
              expect(created_user.contacts).to eq created_contacts
            end
          end

          pending 'allow token creation on user creation'
          # context 'when submitting list of roles for token creation' do
          #   let(:params_with_token_payload) do
          #     user_params[:token_payload] = ['rol1', 'rol2', 'rol3']
          #     user_params
          #   end

          #   it 'creates a token for the new user' do
          #     expect { post :create, params: params_with_token_payload }
          #       .to change(Token, :count).by(1)
          #   end

          #   it 'attaches the token to the user' do
          #     post :create, params: params_with_token_payload
          #     created_user = User.last
          #     created_token = Token.last
          #     expect(created_token.user).to eq created_user
          #   end
          # end
        end
      end

      it_behaves_like 'client user unauthorized', :post, :create
    end
  end

  describe '#show' do
    shared_examples 'show user' do
      it 'returns the user data' do
        user = create :user, :with_contacts
        get :show, params: { id: user.id }
        body = JSON.parse(response.body, symbolize_names: true)

        expect(body).to be_an_instance_of Hash
        expect(body.size).to eq 9
        expect(body.key?(:id)).to be true
        expect(body.key?(:email)).to be true
        expect(body.key?(:context)).to be true
        expect(body.key?(:note)).to be true
        expect(body.key?(:contacts)).to be true
        expect(body.key?(:tokens)).to be true
        expect(body.key?(:allowed_roles)).to be true
        expect(body.key?(:allow_token_creation)).to be true

        expect(body[:contacts]).to be_an_instance_of Array
        expect(body[:contacts].size).to eq 3

        contact_raw = body[:contacts].first
        expect(contact_raw).to be_an_instance_of Hash
        expect(contact_raw.size).to eq 4
        expect(contact_raw.key?(:id)).to be true
        expect(contact_raw.key?(:email)).to be true
        expect(contact_raw.key?(:phone_number)).to be true
        expect(contact_raw.key?(:contact_type)).to be true

        expect(body[:tokens]).to be_an_instance_of Array
        expect(body[:tokens].size).to eq 1
        expect(body[:tokens].first).to be_a(String)

        expect(body[:blacklisted_tokens]).to be_an_instance_of Array
        expect(body[:blacklisted_tokens].size).to eq 0

        expect(body[:allowed_roles]).to be_an(Array)
        expect(body[:allowed_roles].size).to eq(4)
        expect(body[:allowed_roles].first).to be_a(String)
      end
    end

    context 'when requested from an admin' do
      include_context 'admin request'

      context 'when user does not exist' do
        it 'returns 404' do
          get :show, params: { id: 0 }
          expect(response.code).to eq '404'
        end
      end

      context 'show another user' do
        let(:user) { create :user, :with_contacts }

        it_behaves_like 'show user'

        it 'shows blacklisted jwt' do
          jwt = user.jwt_api_entreprise.first
          jwt.update(blacklisted: true)
          get :show, params: { id: user.id }
          expect(response_json)
            .to include blacklisted_tokens: a_collection_containing_exactly(jwt.rehash)
        end
      end

      it 'also returns the user note attribute' do
        user = create :user, :with_contacts
        get :show, params: { id: user.id }
        body = JSON.parse(response.body, symbolize_names: true)

        expect(body).to have_key(:note)
      end
    end

    context 'when requested from a client user' do
      let(:user) { UsersFactory.confirmed_user }
      before { fill_request_headers_with_user_jwt(user.id) }

      it 'returns requesting user\'s info' do
        get :show, params: { id: user.id }

        expect(response.code).to eq '200'
      end

      it 'does not return the user note attribute' do
        get :show, params: { id: user.id }
        body = JSON.parse(response.body, symbolize_names: true)

        expect(body).to_not have_key(:note)
      end

      it 'does not return the user blacklisted jwt' do
        create :jwt_api_entreprise, user: user
        jwt = user.jwt_api_entreprise.first
        jwt.update(blacklisted: true)

        expect(user.blacklisted_jwt.size).to eq 1
        get :show, params: { id: user.id }

        expect(response_json).not_to have_key :blacklisted_tokens
      end

      it 'denies access to other users data' do
        another_user = create(:user)
        get :show, params: { id: another_user.id }

        expect(response.code).to eq '403'
      end
    end
  end

  describe '#destroy' do
    context 'when requested from an admin' do
      include_context 'admin request'

      context 'when user does not exist' do
        it 'returns 404' do
          delete :destroy, params: { id: 0 }
          expect(response.code).to eq '404'
        end

        it 'does not change the database' do
          expect { delete :destroy, params: { id: 0 } }
            .to_not change(User, :count)
        end
      end

      context 'when user exists' do
        it 'returns 204' do
          user = create :user
          delete :destroy, params: { id: user.id }
          expect(response.code).to eq '204'
        end

        it 'deletes the user' do
          user = create :user
          expect { delete :destroy, params: { id: user.id } }
            .to change(User, :count).by(-1)
        end

        # TODO move into user model's specs
        it 'deletes associated contacts' do
          user = create :user, :with_contacts
          expect { delete :destroy, params: { id: user.id } }
            .to change(Contact, :count).by(-3)
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
          cgu_checked: true,
          password: 'validPWD12',
          password_confirmation: 'validPWD12'
        }
      end
      before { post :confirm, params: confirmation_params, as: :json }

      it 'returns 200' do
        expect(response.code).to eq '200'
      end

      it 'returns a session JWT' do
        body = JSON.parse(response.body, symbolize_names: true)
        expect(body[:access_token]).to be_truthy
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
      before { post :confirm, params: confirmation_params }

      it 'returns 422' do
        expect(response.code).to eq '422'
      end
    end
  end

  describe '#add_roles' do
    let(:roles) { create_list(:role, 4) }
    let(:op_params) do
      user = create(:user)
      {
        id: user.id,
        roles: roles.pluck(:id)
      }
    end

    context 'admin request' do
      include_context 'admin request'

      context 'when data is valid' do
        it 'links roles to the user' do
          post :add_roles, params: op_params
          user = User.find(op_params[:id])

          expect(user.roles).to eq(roles)
        end

        it 'returns 200' do
          post :add_roles, params: op_params

          expect(response.code).to eq('200')
        end
      end

      context 'when data is invalid' do
        it 'returns 422' do
          op_params[:id] = 0
          post :add_roles, params: op_params

          expect(response.code).to eq('422')
        end
      end
    end

    it_behaves_like 'client user unauthorized', :post, :add_roles, { id: 'much id', roles: ['rol1'] }
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
end
