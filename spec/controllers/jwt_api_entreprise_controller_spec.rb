require 'rails_helper'

describe JwtApiEntrepriseController, type: :controller do
  let(:token_params) do
    {
      roles:   jwt_roles,
      user_id: user.id,
      subject: 'coucou',
      contact: {
        email:        'valid@email.com',
        phone_number: '0123456789'
      }
    }
  end

  describe '#admin_create' do
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
          expect { post :admin_create, params: token_params }
            .to change(JwtApiEntreprise, :count).by(1)
        end

        it 'returns code 201' do
          post :admin_create, params: token_params
          expect(response.code).to eq '201'
        end

        it 'returns the created JWT' do
          post :admin_create, params: token_params
          body = JSON.parse(response.body, symbolize_names: true)

          expect(body[:new_token]).to be_a(String)
        end
      end

      context 'when data is invalid' do
        it 'must be a valid user' do
          token_params[:user_id] = 0
          post :admin_create, params: token_params
          expect(response.code).to eq '422'
        end

        it 'does not create the token' do
          token_params[:roles] = nil
          expect { post :admin_create, params: token_params }
            .to_not change(JwtApiEntreprise, :count)
        end

        it 'returns code 422' do
          token_params[:roles] = nil
          post :admin_create, params: token_params
          expect(response.code).to eq '422'
        end
      end
    end

    # TODO: find a way to pass arguments outside example groups ('let' variables not not accessible here)
    it_behaves_like 'client user unauthorized', :post, :admin_create, user_id: 0
  end

  describe '#blacklist' do
    let(:jwt) { create :jwt_api_entreprise }

    describe 'admin context' do
      include_context 'admin request'

      it 'blacklist the jwt' do
        post :blacklist, params: { id: jwt.to_param, user_id: jwt.user.id }
        jwt.reload
        expect(jwt).to have_attributes blacklisted: true
        expect(response).to have_http_status :ok
      end
    end

    describe 'normal user context' do
      include_context 'user request'

      it_behaves_like 'client user unauthorized', :post, :blacklist, id: 0, user_id: 0

      it 'does not blacklist the token' do
        post :blacklist, params: { id: jwt.to_param, user_id: jwt.user.id }
        jwt.reload
        expect(jwt).to have_attributes blacklisted: false
      end
    end

    it_behaves_like 'client user unauthorized', :post, :blacklist, id: 0, user_id: 0
  end
end
