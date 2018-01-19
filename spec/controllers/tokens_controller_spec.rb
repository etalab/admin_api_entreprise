require 'rails_helper'

describe TokensController, type: :controller do
  before { set_authentication_token }

  describe '#create' do
    let(:user) do
      result = User::Create.call(email: 'user@test.gg', context: '')
      result['model']
    end
    let(:token_params) do
      { token_payload: %w(rol1 rol2 rol3), user_id: user.id }
    end

    context 'when data is valid' do
      it 'creates a valid token' do
        expect { post :create, params: token_params }
          .to change(Token, :count).by(1)
      end

      it 'returns code 201' do
        post :create, params: token_params
        expect(response.code).to eq '201'
      end
    end

    context 'when data is invalid' do
      it 'must be a valid user' do
        token_params[:user_id] = 0
        post :create, params: token_params
        expect(response.code).to eq '422'
      end

      it 'does not create the token' do
        token_params[:token_payload] = nil
        expect { post :create, params: token_params }
          .to_not change(Token, :count)
      end

      it 'returns code 422' do
        token_params[:token_payload] = nil
        post :create, params: token_params
        expect(response.code).to eq '422'
      end
    end
  end
end
