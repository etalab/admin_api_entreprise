require 'rails_helper'

describe UsersController, type: :controller do
  describe '#index' do
    # TODO pagination handling
    it 'returns all users from database' do
      users = create_list :user, 5
      serialized_users = JSON.parse(users.to_json, symbolize_names: true)
      get :index
      body = JSON.parse(response.body, symbolize_names: true)

      expect(body).to eq serialized_users
      expect(response.code).to eq "200"
    end
  end

  describe '#create' do
    it 'returns an error on invalid params submission' do
      post :create, params: { email: 'not.n.email' }
      body = JSON.parse(response.body, symbolize_names: true)

      expect(response.code).to eq "422"
      expect(body[:errors]).to include('Invalid email')
    end

    # TODO return link for created user
    it 'creates a valid user' do
      user_email = 'coucou@hello.fr'
      post :create, params: { email: user_email }

      expect(response.code).to eq "201"
      expect(User.find_by_email(user_email)).to be
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
        user = create :user
        get :show, params: { id: user.id }
        body = JSON.parse(response.body, symbolize_names: true)

        expect(body).to eq JSON.parse(user.to_json, symbolize_names: true)
      end
    end
  end

  describe '#update' do
    context 'when user does not exist' do
      it 'returns 404' do
        put :update, params: {id: 0, email: 'much@email.wow'}
        expect(response.code).to eq "404"
      end
    end

    context 'when user exists' do
      let(:user) { create :user }

      it 'does not accept invalid data' do
        put :update, params: { id: user.id, email: '' }

        expect(response.code).to eq "422"
        expect(response.body).to include('Invalid email')
      end

      it 'updates and returns the user with valid data' do
        updated_email = 'veryupdate@doge.wow'
        put :update, params: { id: user.id, email: updated_email }
        body = JSON.parse(response.body, symbolize_names: true)

        expect(response.code).to eq "200"
        expect(body[:email]).to eq updated_email
      end

      it 'cannot update the token' do
        old_token = user.token
        put :update, params: { id: user.id, token: 'new_token' }
        expect(user.reload.token).to eq old_token
      end

      # Would have prefer it into model logic, but hard to implement and kind of a business rule
      it 'updates the token when roles are updated' do
        role = create :role
        old_token = user.token
        put :update, params: { id: user.id, roles: [role.id] }
        expect(user.reload.token).not_to eq old_token
      end
    end
  end

  describe '#destroy' do
    context 'when user does not exist' do
      it 'returns 404' do
        delete :destroy, params: { id: 0 }
        expect(response.code).to eq "404"
      end
    end

    context 'when user exists' do
      it 'returns 204 and delete the user' do
        user = create :user
        delete :destroy, params: { id: user.id }

        expect(response.code).to eq "204"
        expect { User.find(user.id) }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
