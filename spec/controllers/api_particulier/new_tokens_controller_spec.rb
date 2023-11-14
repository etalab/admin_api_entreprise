RSpec.describe APIParticulier::NewTokensController do
  subject(:new_tokens_download) { get :download }

  describe 'GET #new_token' do
    context 'when the user is not logged in' do
      before { new_tokens_download }

      it { is_expected.to have_http_status(:found) }
    end

    context 'when the user is logged in' do
      before do
        session[:current_user_id] = user_id
      end

      context 'when there is a matching csv file' do
        let!(:user) { create(:user) }
        let(:user_id) { user.id }

        it { is_expected.to have_http_status(:success) }
      end
    end
  end
end
