require 'rails_helper'

RSpec.describe RecentlyCreatedUsersQuery, type: :service do
  let(:now) { Time.local(2021, 8, 24, 12, 0) } # mardi 24 aout midi

  let!(:created_now_user)               { Timecop.freeze(now);         create(:user) }
  let!(:created_lundi)                  { Timecop.freeze(now - 1.day); create(:user) }
  let!(:created_mardi_dernier)          { Timecop.freeze(now - 7.day); create(:user) }
  let!(:created_lundi_dernier)          { Timecop.freeze(now - 8.day); create(:user) }
  let!(:created_dimanche_en_8_dernier)  { Timecop.freeze(now - 9.day); create(:user) }

  it '#call returns users created this week and last week' do
    Timecop.freeze(now)

    results = described_class.new.perform

    expect(results).to include(*[created_now_user, created_lundi, created_mardi_dernier, created_lundi_dernier])
    expect(results).not_to include(created_dimanche_en_8_dernier)
  end
end
