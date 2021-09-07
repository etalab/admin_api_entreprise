require 'rails_helper'

RSpec.describe TokensQuery, type: :query do
  describe 'expiring_within_interval' do
    let(:now)               { Time.local(2021,8,26,12,0) }
    let(:interval_start)    { 3.days.from_now  }
    let(:interval_stop)     { 10.days.from_now }

    # let postgresql fail and raise error if start == stop or start is after stop

    before do
      Timecop.freeze(now)
    end

    after do
      Timecop.return
    end

    subject(:results) { described_class.new.expiring_within_interval(interval_start: interval_start, interval_stop: interval_stop) }

    let!(:jwt_expiring_within_interval)                 { create(:jwt_api_entreprise, exp: 7.days.from_now) }
    let!(:jwt_expiring_early_within_interval_start_day) { create(:jwt_api_entreprise, exp: interval_start.beginning_of_day) }
    let!(:jwt_expiring_late_within_interval_stop_day)   { create(:jwt_api_entreprise, exp: interval_stop.end_of_day) }

    let!(:jwt_expiring_day_after_interval_stop_day)     { create(:jwt_api_entreprise, exp: interval_stop.end_of_day + 1.second) }
    let!(:jwt_expiring_day_before_interval_start_day)   { create(:jwt_api_entreprise, exp: interval_start.beginning_of_day - 1.second) }

    it 'returns jwt expiring within interval' do
      expect(results).to include(jwt_expiring_within_interval)
    end

    it 'returns jwt expiring outside interval but within beginning of interval_start day' do
      expect(results).to include(jwt_expiring_early_within_interval_start_day)
    end

    it 'returns jwt expiring outside interval but within ending of interval_stop day' do
      expect(results).to include(jwt_expiring_late_within_interval_stop_day)
    end

    it 'does not return jwt expiring outside interval' do
      expect(results).not_to include(jwt_expiring_day_after_interval_stop_day)
      expect(results).not_to include(jwt_expiring_day_before_interval_start_day)
    end
  end
end
