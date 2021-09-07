require 'rails_helper'

RSpec.describe UsersQuery, type: :query do
  describe 'without_token' do
    let!(:user_with_token)     { create(:user, :with_jwt) }
    let!(:user_without_token)  { create(:user) }

    subject(:results) { described_class.new.without_token }

    it 'returns users with no tokens' do
      expect(results).to eq([user_without_token])
    end
  end

  describe 'with_token' do
    let!(:user_with_token)     { create(:user, :with_jwt) }
    let!(:user_without_token)  { create(:user) }

    subject(:results) { described_class.new.with_token }

    it 'returns users with no tokens' do
      expect(results).to eq([user_with_token])
    end
  end
end
