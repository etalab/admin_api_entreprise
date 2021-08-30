require 'rails_helper'

RSpec.describe UsersWithRecentUnusedJwtApiEntrepriseQuery, type: :service do
  let(:now) { Time.local(2021, 8, 24, 12, 0) } # mardi 24 aout midi

  subject { described_class.new.perform }

  before do
    Timecop.freeze(now)
  end

  after do
    Timecop.return
  end

  # user without tokens
  context 'user without tokens' do
    let!(:user) { create(:user) }

    before do
      allow_any_instance_of(UsedJwtIdsElasticQuery).to receive(:perform).and_return([])
    end

    it 'is not included' do
      expect(subject).not_to include(user)
    end
  end

  context 'user with recent used tokens' do
    let!(:user) { create(:user, :with_jwt) }

    before do
      allow_any_instance_of(UsedJwtIdsElasticQuery).to receive(:perform).and_return(
        user.jwt_api_entreprise.pluck(:id)
      )
    end

    it 'is not included' do
      expect(subject).not_to include(user)
    end
  end

  context 'user with rather old unused token' do
    let!(:user) do
      timecoped_now = Time.now
      Timecop.freeze(timecoped_now - 60.days)
      user = create(:user, :with_jwt) # cant use fields created_at and updated_at because it won't work on associated jwt
      Timecop.freeze(timecoped_now)

      user
    end

    before do
      allow_any_instance_of(UsedJwtIdsElasticQuery).to receive(:perform).and_return(
        user.jwt_api_entreprise.pluck(:id)
      )
    end

    it 'is not included' do
      expect(subject).not_to include(user)
    end
  end

  context 'user with one unused recent token and one recently active token' do
    it 'is included' do
      user = create(:user)
      unused_recent_token = create(:jwt_api_entreprise, user: user, created_at: 3.days.ago, updated_at: 3.days.ago)
      recently_active_but_not_recently_created_token = create(:jwt_api_entreprise, user: user, created_at: 30.days.ago, updated_at: 30.days.ago)

      allow_any_instance_of(UsedJwtIdsElasticQuery).to receive(:perform).and_return(
        [recently_active_but_not_recently_created_token.id]
      )

      expect(subject).to include(user)
    end
  end
end
