RSpec.describe APIParticulier::StatsController do
  describe 'GET #index as json' do
    subject(:get_index) { get :index, params: { format: :json } }

    before { get_index }

    it { is_expected.to have_http_status(:success) }
    it { expect(JSON.parse(response.body)).to be_an(Array) }
  end
end
