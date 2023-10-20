RSpec.describe TokenShowDecorator do
  before do
    Timecop.freeze('01/01/2023')
  end

  after do
    Timecop.return
  end

  describe '#passed_time_as_ratio' do
    subject { described_class.new(token).passed_time_as_ratio }

    context 'when token is expired' do
      let(:token) { create(:token, created_at: 1.year.ago, exp: 6.months.ago) }

      it { is_expected.to eq(100) }
    end

    context 'when token is valid' do
      let(:token) { create(:token, created_at: 1.year.ago, exp: 1.year.from_now) }

      it { is_expected.to eq(50) }
    end
  end

  describe '#progress_bar_color' do
    subject { described_class.new(token).progress_bar_color }

    context 'when token is valid for more than 90 days' do
      let(:token) { create(:token, created_at: 1.year.ago, exp: 120.days.from_now) }

      it { is_expected.to eq('green') }
    end

    context 'when token is valid for less than 90 days' do
      let(:token) { create(:token, created_at: 1.year.ago, exp: 89.days.from_now) }

      it { is_expected.to eq('orange') }
    end

    context 'when token is valid for less than 30 days' do
      let(:token) { create(:token, created_at: 1.year.ago, exp: 6.days.from_now) }

      it { is_expected.to eq('red') }
    end
  end

  describe '#status' do
    subject { described_class.new(token).status }

    context 'when expired' do
      let(:token) { create(:token, exp: 1.day.ago) }

      it { is_expected.to eq('expired') }
    end

    context 'when blacklisted' do
      let(:token) { create(:token, blacklisted_at: 1.day.ago) }

      it { is_expected.to eq('revoked') }
    end

    context 'when active' do
      let(:token) { create(:token) }

      it { is_expected.to eq('active') }
    end
  end
end
