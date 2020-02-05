require 'rails_helper'

describe JwtApiEntrepriseController, type: :controller do
  let(:token_params) do
    {
      roles: jwt_roles,
      user_id: user.id,
      subject: 'coucou',
      contact: {
        email: 'valid@email.com',
        phone_number: '0123456789'
      }
    }
  end

  describe '#index' do
    before { create_list(:jwt_api_entreprise, 8) }

    context 'when requested from an admin' do
      include_context 'admin request'

      it 'returns an HTTP code 200' do
        get :index

        expect(response.code).to eq('200')
      end

      it 'returns all JWT from the database' do
        get :index

        expect(response_json.size).to eq(8)
      end

      it 'has a valid payload' do
        get :index

        expect(response_json).to all(
          match({
            id: String,
            user_id: String,
            subject: String,
            iat: Integer,
            exp: Integer,
            blacklisted: be(true).or(be(false)),
            archived: be(true).or(be(false))
          })
        )
      end
    end

    it_behaves_like 'client user unauthorized', :get, :index
  end

  describe '#create' do
    let(:user) { UsersFactory.confirmed_user }
    let(:jwt_roles) do
      roles = create_list(:role, 4)
      roles.map { |role| role.slice(:code) }
    end
    let(:token_params) do
      {
        roles: jwt_roles,
        user_id: user.id,
        authorization_request_id: '1234',
        subject: 'coucou',
        contacts: [
          {
            email: 'coucou@admin.fr',
            phone_number: '0123456789',
            contact_type: 'admin'
          },
          {
            email: 'coucou@tech.fr',
            phone_number: '0987654321',
            contact_type: 'tech'
          }
        ]
      }
    end

    context 'admin request' do
      include_context 'admin request'

      context 'when data is valid' do
        it 'creates a valid token' do
          expect { post :create, params: token_params }
            .to change(JwtApiEntreprise, :count).by(1)
        end

        it 'creates the contacts' do
          expect { post :create, params: token_params }
            .to change(Contact, :count).by(2)
        end

        it 'returns code 201' do
          post :create, params: token_params
          expect(response.code).to eq '201'
        end

        it 'returns the created JWT' do
          post :create, params: token_params

          expect(response_json[:new_token]).to be_a(String)
        end
      end

      context 'when data is invalid' do
        let(:invalid_params) do
          token_params[:user_id] = 0
          token_params
        end

        it 'returns a 422' do
          post :create, params: invalid_params

          expect(response.code).to eq '422'
        end

        it 'returns error messages' do
          post :create, params: invalid_params

          expect(response_json).to match({
            errors: {
              user_id: a_collection_including(String)
            }
          })
        end

        it 'does not create the token' do
          expect { post :create, params: invalid_params }
            .to_not change(JwtApiEntreprise, :count)
        end
      end
    end

    # TODO find a way to pass arguments outside example groups ('let' variables not not accessible here)
    it_behaves_like 'client user unauthorized', :post, :create, { user_id: 0 }
  end

  describe '#update' do
    describe 'admin context' do
      include_context 'admin request'

      context 'when the JWT exists' do
        let(:jwt) { create(:jwt_api_entreprise, archived: false, blacklisted: false) }

        subject(:update!) do
          patch(
            :update,
            params: { id: jwt.id, archived: true, blacklisted: true, subject: 'New subject' },
            as: :json
          )
        end

        it 'changes updatable attributes' do
          update!

          expect(jwt.reload).to have_attributes(archived: true, blacklisted: true)
        end

        it 'ignores non-updatable attributes' do
          update!

          expect(jwt.reload.subject).to_not eq('New subject')
        end

        it 'returns an HTTP code 200' do
          update!

          expect(response.code).to eq('200')
        end
      end

      context 'when the params are invalid' do
        before { patch :update, params: { id: 0 }, as: :json }

        it 'returns an HTTP code 422' do
          expect(response.code).to eq('422')
        end

        it 'returns an error message' do
          expect(response_json).to include(:errors)
        end
      end
    end

    it_behaves_like 'client user unauthorized', :post, :update, { id: 0, user_id: 0 }
  end
end
