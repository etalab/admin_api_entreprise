require 'rails_helper'

describe 'Request authentication', type: :controller do
  # Use of anonymous controller with random action which inherits from
  # ApplicationController to test authentication callback genericity
  controller(ApplicationController) do
    def random_action
      render json: { very: 'random' }, status: 200
    end
  end

  before do
    routes.draw { get 'random_action' => 'anonymous#random_action' }
  end

  context 'when Authorization header is absent' do
    it 'returns 401' do
      get :random_action

      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":"Unauthorized"}'
    end
  end

  context 'when Authorization header is present' do
    # Session JWT generated without expiration date
    let(:valid_token) { 'eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiJiYWNiOWJiYy1mMjA4LTRiMjMtYTE3Ni02NzUwNGQ0OTIwZGQiLCJncmFudHMiOltdLCJhZG1pbiI6dHJ1ZSwiaWF0IjoxNTMwMDE0Njc1fQ.jBC59fOa5aLVeaWoYKCIi2X-HUEVi6iSnLwnUm5kIyw' }

    it 'accepts valid tokens' do
      request.headers['Authorization'] = "Bearer #{valid_token}"
      get :random_action

      expect(response.code).to eq '200'
      expect(response.body).to eq '{"very":"random"}'
    end

    it 'denies invalid header format' do
      request.headers['Authorization'] = "FuBearer : #{valid_token}"
      get :random_action

      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":"Unauthorized"}'
    end

    it 'denies invalid tokens' do
      request.headers['Authorization'] = 'Bearer invalid_token'
      get :random_action

      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":"Unauthorized"}'
    end

    pending 'denies unwell-signed tokens'
  end

  # Login action resides in Doorkeeper::TokensController which does not
  # inherits from ApplicationController
  describe 'Login action', type: :request do
    let(:user) { create(:user) }

    it 'does not require token authentication' do
      login_params = {
        username: user.email,
        password: user.password,
        grant_type: 'password'
      }
      post '/api/admin/users/login', params: login_params

      expect(response.code).to eq '200'
      expect(response.body).to include 'access_token'
    end

    context 'when admin logs in' do
      let(:admin) { create(:user, :admin) }

      it 'issues a JWT with admin role' do
        login_params = {
          username: admin.email,
          password: AuthenticationHelper::ADMIN_PWD,
          grant_type: 'password'
        }
        post '/api/admin/users/login', params: login_params
        body = JSON.parse(response.body, symbolize_names: true)
        jwt = body.fetch(:access_token)

        expect(response.code).to eq '200'
        expect(extract_payload_from(jwt).fetch(:admin)).to eq true
      end
    end
  end
end
