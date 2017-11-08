require 'rails_helper'

describe UsersController, type: :controller do
  describe '#index' do
    # TODO pagination handling
    let(:nb_users) { 10 }
    before do
      create_list :user, nb_users
      get :index
    end

    it 'returns all users from database' do
      body = JSON.parse(response.body, symbolize_names: true)

      expect(body.size).to eq nb_users
      expect(response.code).to eq "200"
    end

    it 'returns the correct payload format' do
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body).to be_an_instance_of Array

      user_raw = body.first
      expect(user_raw).to be_an_instance_of Hash
      expect(user_raw.size).to eq 3
      expect(user_raw.has_key? :id).to be true
      expect(user_raw.has_key? :email).to be true
      expect(user_raw.has_key? :context).to be true
    end
  end

  describe '#create' do
    # getting attributes from :user Factory
    let(:user_params) { attributes_for :user }

    context 'when data is not valid' do
      before do
        allow_any_instance_of(UserForm::Create).to receive(:validate).and_return(false)
        post :create, params: user_params
      end

      it 'returns code 422' do
        expect(response.code).to eq "422"
      end

      it 'returns errors' do
        body = JSON.parse(response.body, symbolize_names: true)
        expect(body[:errors]).to be_an_instance_of Hash
      end
    end

    context 'when data is valid' do
      it 'saves the user into the database' do
        expect { post :create, params: user_params }.to change(User, :count).by 1
      end

      it 'returns code 201' do
        post :create, params: user_params
        expect(response.code).to eq "201"
      end

      context 'when submitting data for contacts creation' do
        let(:params_with_contacts) do
          user_params[:contacts] = []
          user_params[:contacts]
            .append(attributes_for :contact, contact_type: 'admin')
            .append(attributes_for :contact, contact_type: 'tech')
            .append(attributes_for :contact, contact_type: 'other')
          user_params
        end

        it 'creates the contacts' do
          expect { post :create, params: params_with_contacts }.to change(Contact, :count).by(3)
        end

        it 'associates the created contacts to the user' do
          post :create, params: params_with_contacts
          created_user = User.last
          created_contacts = Contact.last(params_with_contacts[:contacts].size)
          expect(created_user.contacts).to eq created_contacts
        end
      end

      context 'when submitting list of roles for token creation' do
        let(:params_with_token_payload) do
          user_params[:token_payload] = ['rol1', 'rol2', 'rol3']
          user_params
        end

        it 'creates a token for the new user' do
          expect { post :create, params: params_with_token_payload }.to change(Token, :count).by(1)
        end

        it 'attaches the token to the user' do
          post :create, params: params_with_token_payload
          created_user = User.last
          created_token = Token.last
          expect(created_token.user).to eq created_user
        end
      end
    end
  end

  describe '#show' do
    context 'when user does not exist' do
      it 'returns 404' do
        get :show, params: { id: 0 }
        expect(response.code).to eq "404"
      end
    end

    context 'when user exists' do
      it 'returns the user data' do
        user = create :user_with_contacts
        get :show, params: { id: user.id }
        body = JSON.parse(response.body, symbolize_names: true)

        expect(body).to be_an_instance_of Hash
        expect(body.size).to eq 5
        expect(body.has_key? :id).to be true
        expect(body.has_key? :email).to be true
        expect(body.has_key? :context).to be true
        expect(body.has_key? :contacts).to be true
        expect(body.has_key? :tokens).to be true

        expect(body[:contacts]).to be_an_instance_of Array
        expect(body[:contacts].size).to eq 3

        contact_raw = body[:contacts].first
        expect(contact_raw).to be_an_instance_of Hash
        expect(contact_raw.size).to eq 4
        expect(contact_raw.has_key? :id).to be true
        expect(contact_raw.has_key? :email).to be true
        expect(contact_raw.has_key? :phone_number).to be true
        expect(contact_raw.has_key? :contact_type).to be true

        expect(body[:tokens]).to be_an_instance_of Array
        expect(body[:tokens].size).to eq 1
      end
    end
  end

  describe '#update' do
    context 'when user does not exist' do
      it 'returns 404' do
        put :update, params: { id: 0, email: 'much@email.wow' }
        expect(response.code).to eq "404"
      end
    end

    context 'when user exists' do
      let!(:user) { create :user }

      context 'when data is invalid' do
        it 'return code 422' do
          allow_any_instance_of(User).to receive(:valid?).and_return(false)
          put :update, params: { id: user.id, email: 'dotnotcare' }
          expect(response.code).to eq "422"
        end
      end

      context 'when no updating fields are present' do
        it 'returns code 400' do
          put :update, params: { id: user.id }
          expect(response.code).to eq "400"
        end
      end

      context 'when params are valid' do
        let(:user_params) { attributes_for :user }

        it 'returns code 200' do
          allow_any_instance_of(User).to receive(:valid?).and_return(true)
          put :update, params: user_params.merge({ id: user.id })
          expect(response.code).to eq "200"
        end

        it 'updates the email' do
          new_email = 'new@mail.wow'
          put :update, params: { id: user.id, email: new_email }
          expect(user.reload.email).to eq new_email
        end

        it 'updates the context' do
          new_context = 'new context'
          put :update, params: { id: user.id, context: new_context }
          expect(user.reload.context).to eq new_context
        end
      end
    end
  end

  describe '#destroy' do
    context 'when user does not exist' do
      it 'returns 404' do
        delete :destroy, params: { id: 0 }
        expect(response.code).to eq "404"
      end

      it 'does not change the database' do
        expect { delete :destroy, params: { id: 0} }.to_not change(User, :count)
      end
    end

    context 'when user exists' do
      it 'returns 204' do
        user = create :user
        delete :destroy, params: { id: user.id }
        expect(response.code).to eq "204"
      end

      it 'deletes the user' do
        user = create :user
        expect { delete :destroy, params: { id: user.id } }.to change(User, :count).by(-1)
      end

      # TODO move into user model's specs
      it 'deletes associated contacts' do
        user = create :user_with_contacts
        expect { delete :destroy, params: { id: user.id } }.to change(Contact, :count).by(-3)
      end

      pending 'it deletes associated tokens'
    end
  end
end
