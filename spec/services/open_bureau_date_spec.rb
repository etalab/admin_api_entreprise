require 'rails_helper'

RSpec.describe OpenBureauDate, type: :service do
  describe '#next' do
    subject { described_class.new.next_date.to_s }

    context 'when date is the third tuesday of the month' do
      before do
        Timecop.freeze(Date.new(2021, 9, 10))
      end

      let(:next_date) { Date.new(2021, 9, 21) }

      it { is_expected.to eq(next_date.to_s) }
    end

    context 'when date is the first tuesday of the month' do
      before do
        Timecop.freeze(Date.new(2021, 9, 1))
      end

      let(:next_date) { Date.new(2021, 9, 7) }

      it { is_expected.to eq(next_date.to_s) }
    end

    context 'when today is open bureau day' do
      context 'when before 11:00' do
        before do
          Timecop.freeze(DateTime.new(2022, 10, 4, 8).in_time_zone('Europe/Paris'))
        end

        let(:today_date) { Date.new(2022, 10, 4) }

        it { is_expected.to eq(today_date.to_s) }
      end

      context 'when after 11:00' do
        before do
          Timecop.freeze(DateTime.new(2022, 10, 4, 12).in_time_zone('Europe/Paris'))
        end

        let(:next_date) { Date.new(2022, 10, 18) }

        it { is_expected.to eq(next_date.to_s) }
      end
    end

    describe 'non-regression tests' do
      context 'when first tuesday is on 1st of month, before this date' do
        before do
          Timecop.freeze(Date.new(2022, 10, 31))
        end

        let(:next_date) { Date.new(2022, 11, 1) }

        it { is_expected.to eq(next_date.to_s) }
      end

      context 'when first tuesday is on 1st of month, after this date' do
        before do
          Timecop.freeze(Date.new(2024, 10, 2))
        end

        let(:next_date) { Date.new(2024, 10, 15) }

        it { is_expected.to eq(next_date.to_s) }
      end
    end

    describe 'when it is a cancelled date' do
      before do
        Timecop.freeze(Date.new(2024, 11, 12))
        allow(YAML).to receive(:load_file).and_return(['2024-11-19'])
      end

      let(:next_date) { Date.new(2024, 12, 3) }

      it { is_expected.to eq(next_date.to_s) }
    end
  end
end
