require 'rails_helper'

describe JwtApiEntrepriseController, type: :controller do
  describe '#create' do
    let(:user) { UsersFactory.confirmed_user }
    let(:jwt_roles) do
      roles = create_list(:role, 4)
      roles.pluck(:code)
    end
    let(:token_params) do
      { roles: jwt_roles, user_id: user.id, subject: 'coucou' }
    end

    context 'admin request' do
      include_context 'admin request'

      context 'when data is valid' do
        it 'creates a valid token' do
          expect { post :create, params: token_params }
            .to change(JwtApiEntreprise, :count).by(1)
        end

        it 'returns code 201' do
          post :create, params: token_params
          expect(response.code).to eq '201'
        end

        it 'returns the created JWT' do
          post :create, params: token_params
          body = JSON.parse(response.body, symbolize_names: true)

          expect(body[:new_token]).to be_a(String)
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
            .to_not change(JwtApiEntreprise, :count)
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
