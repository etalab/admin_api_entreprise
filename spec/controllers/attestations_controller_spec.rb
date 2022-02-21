require 'rails_helper'

RSpec.describe AttestationsController, type: :controller do
  let(:user) { create(:user, :with_jwt_specific_roles, specific_roles: ['attestations_sociales']) }
  let(:jwt) { user.jwt_api_entreprise.first }

  before { session[:current_user_id] = user.id }

  describe '#new' do
    let(:jwt_codes) { controller.instance_variable_get(:@jwt_attestations_roles)&.map(&:code) }

    context 'when jwt_id' do
      before { get :new, params: { jwt_id: jwt.id }, format: :turbo_stream }

      it 'sets up correct @jwt_attestations_roles' do
        expect(jwt_codes).to eq(['attestations_sociales'])
      end
    end

    context 'when no jwt_id' do
      before { get :new, params: { jwt_id: nil }, format: :turbo_stream }

      it 'sets up nil @jwt_attestations_roles' do
        expect(jwt_codes).to eq(nil)
      end
    end
  end

  describe '#search' do
    let(:results) { controller.instance_variable_get(:@results) }

    context 'when searching for a siret', vcr: { cassette_name: 'controllers/attestations_search' } do
      before do
        get :search, params: { siret: siret_valid, token: apientreprise_test_token }, format: :turbo_stream
      end

      it 'find results' do
        expect(results).to include('JK ASSOCIATES CONSULTING')
      end
    end
  end
end
