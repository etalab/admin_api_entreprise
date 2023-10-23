require 'rails_helper'

RSpec.describe AccessLog do
  let(:access_log) { create(:access_log) }

  it 'has valid factories' do
    expect(build(:access_log)).to be_valid
  end

  describe '.since scope' do
    subject { described_class.since(timestamp) }

    let(:timestamp) { 1.day.ago }
    let!(:token) { create(:token) }

    let!(:recent_access_logs) do
      [
        create(:access_log, token:, timestamp: 1.hour.ago),
        create(:access_log, token:, timestamp: 2.hours.ago),
        create(:access_log, token:, timestamp: 3.hours.ago)
      ]
    end

    let!(:old_access_logs) do
      create(:access_log, token:, timestamp: 2.days.ago)
    end

    it 'fetches only access logs since the given timestamp' do
      expect(subject.count).to eq(3)
      expect(subject.first.token_id).to eq(token.id)
    end
  end
end
