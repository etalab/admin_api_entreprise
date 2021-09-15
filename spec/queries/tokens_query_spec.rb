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

    subject(:results) { described_class.new.expiring_within_interval(interval_start: interval_start, interval_stop: interval_stop).results }

    let!(:token_expiring_within_interval)                 { create(:jwt_api_entreprise, exp: 7.days.from_now) }
    let!(:token_expiring_early_within_interval_start_day) { create(:jwt_api_entreprise, exp: interval_start.beginning_of_day) }
    let!(:token_expiring_late_within_interval_stop_day)   { create(:jwt_api_entreprise, exp: interval_stop.end_of_day) }

    let!(:token_expiring_day_after_interval_stop_day)     { create(:jwt_api_entreprise, exp: interval_stop.end_of_day + 1.second) }
    let!(:token_expiring_day_before_interval_start_day)   { create(:jwt_api_entreprise, exp: interval_start.beginning_of_day - 1.second) }

    it 'returns token expiring within interval' do
      expect(results).to include(token_expiring_within_interval)
    end

    it 'returns token expiring outside interval but within beginning of interval_start day' do
      expect(results).to include(token_expiring_early_within_interval_start_day)
    end

    it 'returns token expiring outside interval but within ending of interval_stop day' do
      expect(results).to include(token_expiring_late_within_interval_stop_day)
    end

    it 'does not return token expiring outside interval' do
      expect(results).not_to include(token_expiring_day_after_interval_stop_day)
      expect(results).not_to include(token_expiring_day_before_interval_start_day)
    end
  end

  describe 'unused' do
    let!(:used_token)   { create(:jwt_api_entreprise) }
    let!(:unused_token) { create(:jwt_api_entreprise) }

    before do
      allow_any_instance_of(UsedJwtIdsElasticQuery).to receive(:perform).and_return(
        used_token.id
      )
    end

    subject(:results) { described_class.new.unused.results }

    it 'returns unused_tokens only' do
      expect(results).to eq([unused_token])
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

    def create_token_at(time)
      create(:jwt_api_entreprise, created_at: time, updated_at: time)
    end

    let!(:created_now_token)              { create_token_at(now) }
    let!(:created_lundi)                  { create_token_at(now - 1.day) }

    let!(:created_mardi_dernier)          { create_token_at(now - 7.day) }
    let!(:created_lundi_dernier)          { create_token_at(now - 8.day) }
    let!(:created_dimanche_en_8_dernier)  { create_token_at(now - 9.day) }

    subject(:results) { described_class.new.recently_created.results }

    it 'returns tokens created this week and last week' do
      expect(results).to include(*[
        created_now_token,
        created_lundi,
        created_mardi_dernier,
        created_lundi_dernier
      ])

      expect(results).not_to include(created_dimanche_en_8_dernier)
    end
  end

  describe 'relevent' do
    let(:now) { Time.local(2021, 8, 24, 12, 0) } # mardi 24 aout midi

    before do
      Timecop.freeze(now)
    end

    after do
      Timecop.return
    end

    let!(:already_expired_token) { create(:jwt_api_entreprise, exp: now.yesterday) }
    let!(:blacklisted_token)     { create(:jwt_api_entreprise, blacklisted: true) }
    let!(:archived_token)        { create(:jwt_api_entreprise, archived: true) }
    let!(:relevent_token)        { create(:jwt_api_entreprise, exp: 1.year.from_now, blacklisted: nil, archived: nil) }
    let!(:uptime_robot_token)    { create(:jwt_api_entreprise, subject: 'mon token UptimeRobot interne') }

    subject(:results) { described_class.new.relevent.results }

    it 'returns tokens not expired, archived, blacklisted or used for uptime robot' do
      expect(results).to eq([relevent_token])
    end
  end

  describe 'default scope' do
    let(:now) { Time.local(2021, 8, 24, 12, 0) } # mardi 24 aout midi

    before do
      Timecop.freeze(now)
    end

    after do
      Timecop.return
    end

    let!(:already_expired_token) { create(:jwt_api_entreprise, exp: now.yesterday) }
    let!(:blacklisted_token)     { create(:jwt_api_entreprise, blacklisted: true) }
    let!(:archived_token)        { create(:jwt_api_entreprise, archived: true) }
    let!(:relevent_token)        { create(:jwt_api_entreprise, exp: 1.year.from_now, blacklisted: nil, archived: nil) }
    let!(:uptime_robot_token)    { create(:jwt_api_entreprise, subject: 'mon token UptimeRobot interne') }

    subject(:results) { described_class.new..results }

    it 'returns relevent tokens only' do
      expect(described_class.new.results.to_a).to eq(described_class.new.relevent.results.to_a)
    end
  end
end
