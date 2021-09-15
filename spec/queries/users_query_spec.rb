require 'rails_helper'

RSpec.describe UsersQuery, type: :query do
  describe 'without_token' do
    let!(:user_with_token)     { create(:user, :with_jwt) }
    let!(:user_without_token)  { create(:user) }

    subject(:results) { described_class.new.without_token.results }

    it 'returns users with no tokens' do
      expect(results).to eq([user_without_token])
    end
  end

  describe 'with_token' do
    let!(:user_with_token)     { create(:user, :with_jwt) }
    let!(:user_without_token)  { create(:user) }

    subject(:results) { described_class.new.with_token.results }

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

    subject(:results) { described_class.new.recently_created.results }

    it 'returns users created this week and last week' do
      expect(results).to include(*[
        created_now_user,
        created_lundi,
        created_mardi_dernier,
        created_lundi_dernier
      ])

      expect(results).not_to include(created_dimanche_en_8_dernier)
    end
  end

  describe 'relevent' do
    let!(:admin_user)   { create(:user, admin: true) }
    let!(:regular_user) { create(:user) }

    subject(:results) { described_class.new.relevent.results }

    it 'returns users not admin' do
      expect(results.to_a).to eq([regular_user])
    end
  end

  describe 'default scope' do
    let!(:admin_user)   { create(:user, admin: true) }
    let!(:regular_user) { create(:user) }

    it 'returns relevent users' do
      expect(described_class.new.results.to_a).to eq(described_class.new.relevent.results.to_a)
    end
  end
end
