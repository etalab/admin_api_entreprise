require 'rails_helper'

RSpec.describe UsersWithRecentUnusedJwtApiEntrepriseQuery, type: :service do
  let(:now) { Time.local(2021, 8, 24, 12, 0) } # mardi 24 aout midi

  subject { described_class.new.perform }

  before do
    Timecop.freeze(now)
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
    let!(:user) { Timecop.freeze(now - 60.days); create(:user, :with_jwt) }

    before do
      allow_any_instance_of(UsedJwtIdsElasticQuery).to receive(:perform).and_return(
        user.jwt_api_entreprise.pluck(:id)
      )
    end

    it 'is not included' do
      expect(subject).not_to include(user)
    end
  end

  context 'user with recent tokens and one recently active token' do
    let!(:user) { Timecop.freeze(now - 60.days); create(:user) }
  end

  # # user with one unused token and one recently active token
  # -> expect include

end
