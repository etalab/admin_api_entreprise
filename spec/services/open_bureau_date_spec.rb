require 'rails_helper'

RSpec.describe OpenBureauDate, type: :service do
  describe '#next' do
    subject { described_class.new.next_date }

    before do
      Timecop.freeze(Date.new(2021, 9, 10))
    end

    it { is_expected.to eq('21/09/2021') }
  end

  describe '#next_with_time' do
    subject { described_class.new.next_date_with_time }

    before do
      Timecop.freeze(Date.new(2023, 12, 30))
    end

    it { is_expected.to eq('02/01/2024 à 10 heures') }
  end
end
