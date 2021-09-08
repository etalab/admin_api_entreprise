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

  describe 'recently_created' do
    let(:now) { Time.local(2021, 8, 24, 12, 0) } # mardi 24 aout midi

    before do
      Timecop.freeze(now)
    end

    after do
      Timecop.return
    end

    def create_user_at(time)
      create(:user, created_at: time, updated_at: time)
    end

    let!(:created_now_user)               { create_user_at(now) }
    let!(:created_lundi)                  { create_user_at(now - 1.day) }

    let!(:created_mardi_dernier)          { create_user_at(now - 7.day) }
    let!(:created_lundi_dernier)          { create_user_at(now - 8.day) }
    let!(:created_dimanche_en_8_dernier)  { create_user_at(now - 9.day) }

    subject(:results) { described_class.new.recently_created }

    it '#call returns users created this week and last week' do
      expect(results).to include(*[
        created_now_user,
        created_lundi,
        created_mardi_dernier,
        created_lundi_dernier
      ])

      expect(results).not_to include(created_dimanche_en_8_dernier)
    end
  end
end
