require 'rails_helper'

RSpec.describe JwtApiEntrepriseController, type: :controller do
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
            archived: be(true).or(be(false)),
            authorization_request_id: String
          })
        )
      end
    end

    it_behaves_like 'client user unauthorized', :get, :index
  end

  describe '#create' do
    let(:user) { create(:user) }
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

  describe '#magic_link' do
    subject(:call!) do
      post :create_magic_link, params: { id: jwt_id, email: email }
    end

    shared_examples :magic_links do
      context 'when the JWT ID does not exist' do
        let(:jwt_id) { '0' }
        let(:email) { 'whatever' }

        it 'returns 404' do
          call!

          expect(response.status).to eq(404)
        end

        it 'returns an error message' do
          call!

          expect(response_json).to match({
            errors: { id: ["JWT with id #{jwt_id} is not found."] }
          })
        end

        it 'does not send a magic link through email' do
          expect { call! }
            .to_not have_enqueued_mail(JwtApiEntrepriseMailer, :magic_link)
        end
      end

      context 'when the JWT ID exists' do
        let(:jwt) { create(:jwt_api_entreprise) }
        let(:jwt_id) { jwt.id }

        context 'when the email address is not valid' do
          let(:email) { 'not valid' }

          it 'returns a 422' do
            call!

            expect(response.status).to eq(422)
          end

          it 'returns the validation error messages' do
            call!

            expect(response_json).to match({
              errors: { email: ['is in invalid format'] }
            })
          end

          it 'does not send a magic link through email' do
            expect { call! }
              .to_not have_enqueued_mail(JwtApiEntrepriseMailer, :magic_link)
          end
        end

        context 'when the email address is valid' do
          let(:email) { 'valid@yopmail.fr' }

          it 'returns a 200' do
            call!

            expect(response.status).to eq(200)
          end

          it 'sends a magic link through email' do
            expect { call! }
              .to have_enqueued_mail(JwtApiEntrepriseMailer, :magic_link)
              .with(args: [email, jwt])
          end
        end
      end
    end

    context 'when requested by an admin' do
      include_context 'admin request'

      it_behaves_like :magic_links
    end

    context 'when requested by the user owning the token' do
      let(:jwt) { create(:jwt_api_entreprise) }

      before do
        fill_request_headers_with_user_jwt(jwt.user.id)
      end

      it_behaves_like :magic_links
    end

    context 'when requested by a user that does not own the token' do
      include_context 'user request'

      let(:jwt) { create(:jwt_api_entreprise) }
      let(:jwt_id) { jwt.id }
      let(:email) { 'valid@yopmail.fr' }

      before { call! }

      it 'returns HTTP code 403' do
        expect(response.status).to eq(403)
      end

      it 'returns an error message' do
        expect(response_json).to match({
          errors: "Unauthorized"
        })
      end

      it 'does not send a magic link through email' do
        expect { call! }
          .to_not have_enqueued_mail(JwtApiEntrepriseMailer, :magic_link)
      end
    end
  end

  describe '#show_magic_link' do
    subject(:call!) do
      get :show_magic_link, params: { token: token }
    end

    context 'when the token does not exist' do
      let(:token) { 'not a valid token' }

      it 'returns HTTP code 404' do
        call!

        expect(response.status).to eq(404)
      end

      it 'returns an error message' do
        call!

        expect(response_json).to match({
          errors: { token: ['not a valid token'] }
        })
      end
    end

    context 'when the token exists' do
      let!(:jwt) { create(:jwt_api_entreprise, :with_magic_link) }
      let(:token) { jwt.magic_link_token }

      context 'when the token is expired' do
        before { Timecop.freeze(Time.zone.now + 4.hours) }
        after { Timecop.return }

        it 'returns HTTP code 404' do
          call!

          expect(response.status).to eq(404)
        end

        it 'returns an error message' do
          call!

          expect(response_json).to match({
            errors: { token: ['not a valid token'] }
          })
        end
      end

      context 'when the token is valid' do
        it 'returns HTTP code 200' do
          call!

          expect(response.status).to eq(200)
        end

        it 'returns the JWT payload' do
          call!

          expect(response_json).to include(
            id: jwt.id,
            authorization_request_id: jwt.authorization_request_id,
            iat: jwt.iat,
            exp: jwt.exp,
            blacklisted: jwt.blacklisted,
            archived: jwt.archived,
            subject: jwt.subject,
            secret_key: jwt.rehash,
            roles: a_collection_containing_exactly(*jwt.roles.pluck(:code)),
          )
        end
      end
    end
  end
end
