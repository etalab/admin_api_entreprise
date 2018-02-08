require 'rails_helper'

describe TokensController, type: :controller do
  describe '#create' do
    let(:user) do
      result = User::Create.call(email: 'user@test.gg', context: '')
      result['model']
    end
    let(:token_params) do
      { roles: %w(rol1 rol2 rol3), user_id: user.id }
    end

    context 'admin request' do
      include_context 'admin request'

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
          token_params[:roles] = nil
          expect { post :create, params: token_params }
            .to_not change(Token, :count)
        end

        it 'returns code 422' do
          token_params[:roles] = nil
          post :create, params: token_params
          expect(response.code).to eq '422'
        end
      end
    end

    # TODO find a way to pass arguments outside example groups ('let' variables not not accessible here)
    it_behaves_like 'client user unauthorized', :post, :create, { user_id: 0 }
  end
end
