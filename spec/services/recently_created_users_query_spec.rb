require 'rails_helper'

RSpec.describe RecentlyCreatedUsersQuery, type: :service do
  let(:now) { Time.local(2021, 8, 24, 12, 0) } # mardi 24 aout midi

  let!(:created_now_user)               { t = now;         create(:user, created_at: t, updated_at: t) }
  let!(:created_lundi)                  { t = now - 1.day; create(:user, created_at: t, updated_at: t) }

  let!(:created_mardi_dernier)          { t = now - 7.day; create(:user, created_at: t, updated_at: t) }
  let!(:created_lundi_dernier)          { t = now - 8.day; create(:user, created_at: t, updated_at: t) }
  let!(:created_dimanche_en_8_dernier)  { t = now - 9.day; create(:user, created_at: t, updated_at: t) }

  before do
    Timecop.freeze(now)
  end

  after do
    Timecop.return
  end

  subject(:results) { described_class.new.perform }

  it '#call returns users created this week and last week' do
    expect(results).to include(*[created_now_user, created_lundi, created_mardi_dernier, created_lundi_dernier])
    expect(results).not_to include(created_dimanche_en_8_dernier)
  end
end
