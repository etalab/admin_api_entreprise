require 'rails_helper'

RSpec.describe APIController, type: :controller do
  # Use of anonymous controller with random action which inherits from
  # ApplicationController to test authentication callback genericity
  controller do
    def random_action
      render json: { very: 'random' }, status: 200
    end
  end

  before do
    routes.draw { get 'random_action' => 'api#random_action' }
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
end
