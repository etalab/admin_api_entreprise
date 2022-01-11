require 'rails_helper'

RSpec.describe UsersQuery, type: :query do
  def create_user_at(time)
    create(:user, created_at: time, updated_at: time)
  end

  let(:mardi_24_aout)   { Time.local(2021,8,24,12,0) }

  describe 'with_token' do
    let!(:user_with_token)     { create(:user, :with_jwt) }
    let!(:user_without_token)  { create(:user) }
    let!(:user_with_pending_authorization_request_and_token) do
      u = create(:user, :with_jwt)
      create(:authorization_request, user: u)

      u
    end
    let!(:user_with_pending_authorization_request_only) do
      u = create(:user)
      create(:authorization_request, user: u)

      u
    end

    subject(:results) { described_class.new.with_token.results }

    it 'returns users with tokens' do
      expect(results.to_a).to eq([user_with_token, user_with_pending_authorization_request_and_token])
    end
  end

  describe 'without_token' do
    let!(:user_with_token)     { create(:user, :with_jwt) }
    let!(:user_without_token)  { create(:user) }
    let!(:user_with_pending_authorization_request_and_token) do
      u = create(:user, :with_jwt)
      create(:authorization_request, user: u)

      u
    end
    let!(:user_with_pending_authorization_request_only) do
      u = create(:user)
      create(:authorization_request, user: u)

      u
    end

    subject(:results) { described_class.new.without_token.results }

    it 'returns users with no tokens' do
      expect(results.to_a).to eq([user_without_token, user_with_pending_authorization_request_only])
    end
  end

  describe 'recently_created' do
    let(:now) { mardi_24_aout }

    before do
      Timecop.freeze(now)
    end

    after do
      Timecop.return
    end

    let!(:created_now_user)               { create_user_at(now) }
    let!(:created_lundi)                  { create_user_at(1.day.ago) }

    let!(:created_mardi_dernier)          { create_user_at(7.day.ago) }
    let!(:created_lundi_dernier)          { create_user_at(8.day.ago) }
    let!(:created_dimanche_en_8_dernier)  { create_user_at(9.day.ago) }

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

  describe 'relevant' do
    let!(:admin_user)   { create(:user, admin: true) }
    let!(:regular_user) { create(:user) }

    subject(:results) { described_class.new.relevant.results }

    it 'returns users not admin' do
      expect(results.to_a).to eq([regular_user])
    end
  end

  describe 'default scope' do
    let!(:admin_user)   { create(:user, admin: true) }
    let!(:regular_user) { create(:user) }

    it 'returns relevant users' do
      expect(described_class.new.results.to_a).to eq(described_class.new.relevant.results.to_a)
    end
  end

  describe 'with_production_delayed_token' do
    let(:now) { mardi_24_aout }

    before do
      Timecop.freeze(now)
    end

    after do
      Timecop.return
    end

    let!(:user_with_production_delayed_tokens) { create(:user) }
    let!(:production_delayed_token_1) { create(:jwt_api_entreprise, user: user_with_production_delayed_tokens, created_at: 45.day.ago, updated_at: 45.day.ago) }
    let!(:production_delayed_token_2) { create(:jwt_api_entreprise, user: user_with_production_delayed_tokens, created_at: 45.day.ago, updated_at: 45.day.ago) }

    let!(:user_without_production_delayed_token) { create(:user) }

    subject(:results) { described_class.new.with_production_delayed_token.results }

    it 'returns distinct users having at least one production delayed token (30 day+)' do
      allow_any_instance_of(NotInProductionJwtIdsElasticQuery).to receive(:perform).and_return(
        [production_delayed_token_1.id, production_delayed_token_2.id]
      )

      expect(results.to_a).to eq([user_with_production_delayed_tokens])
    end
  end
end
