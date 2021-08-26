require 'rails_helper'

RSpec.describe JwtApiEntrepriseExpiringWithinIntervalQuery, type: :service do
  let(:now)               { Time.local(2021,8,26,12,0) }
  let(:interval_start)    { 3.days.from_now  }
  let(:interval_stop)     { 10.days.from_now }

  # let postgresql fail and raise error if start == stop or start is after stop

  before do
    Timecop.freeze(now)
  end

  subject { described_class.new(interval_start: interval_start, interval_stop: interval_stop) }

  let(:results) { subject.perform }

  it 'returns jwt expiring within interval' do
    jwt = create_list(:jwt_api_entreprise, 2, exp: 7.days.from_now)

    expect(results).to include(*jwt)
  end

  it 'returns jwt expiring outside interval but within beginning of interval_start day' do
    jwt = create(:jwt_api_entreprise, exp: interval_start.beginning_of_day)

    expect(results).to include(jwt)
  end

  it 'returns jwt expiring outside interval but within ending of interval_stop day' do
    jwt = create(:jwt_api_entreprise, exp: interval_stop.end_of_day)

    expect(results).to include(jwt)
  end

  it 'does not return jwt expiring outside interval' do
    jwt1 = create(:jwt_api_entreprise, exp: interval_start.beginning_of_day - 1.second)
    jwt2 = create(:jwt_api_entreprise, exp: interval_stop.end_of_day + 1.second)


    expect(results).not_to include(jwt1)
    expect(results).not_to include(jwt2)
  end
end
