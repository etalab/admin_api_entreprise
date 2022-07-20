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
  end
end
