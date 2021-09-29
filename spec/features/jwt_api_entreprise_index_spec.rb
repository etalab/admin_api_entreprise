require 'rails_helper'

RSpec.describe 'User JWT listing', type: :feature do
  let(:user) { create(:user) }
  subject(:jwt_index) { visit user_jwt_api_entreprise_index_path(user.id) }

  context 'when the user is not authenticated' do
    it 'redirects to the login' do
      jwt_index

      expect(page.current_path).to eq(login_path)
    end
  end

  context 'when the user is authenticated' do
    before { log_as(authenticated_user) }

    context 'when another user JWTs are requested' do
      let(:authenticated_user) { create(:user) }

      it 'redirects to the authenticated user details' do
        jwt_index

        expect(page.current_path).to eq(user_path(authenticated_user.id))
      end
    end

    context 'when the authenticated user requests his own JWTs' do
      let(:authenticated_user) { user }

      it 'works' do
        jwt_index

        expect(page.current_path).to eq(user_jwt_api_entreprise_index_path(user.id))
      end
    end
  end
end
