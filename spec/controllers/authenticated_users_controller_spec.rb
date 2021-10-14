require 'rails_helper'

RSpec.describe AuthenticatedUsersController, type: :controller do
  controller do
    def index
      render head: :ok
    end
  end

  describe 'when there is a current_user_id with an id which is not in database' do
    before do
      session[:current_user_id] = '1234567890'
    end

    it 'redirects to login path' do
      get :index

      expect(response).to redirect_to(login_path)
    end

    it 'cleans current_user_id session value' do
      expect {
        get :index
      }.to change { session[:current_user_id] }.to(nil)
    end
  end
end
