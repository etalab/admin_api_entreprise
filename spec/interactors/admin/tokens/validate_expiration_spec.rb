require 'rails_helper'

RSpec.describe Admin::Tokens::ValidateExpiration, type: :interactor do
  subject(:result) { described_class.call(exp_date:) }

  before { Timecop.freeze }

  after { Timecop.return }

  context 'when exp_date is nil' do
    let(:exp_date) { nil }

    it { is_expected.to be_a_success }

    it 'defaults to 18 months from now' do
      expect(result.exp).to eq(18.months.from_now.to_i)
    end
  end

  context 'when exp_date is a valid future date' do
    let(:exp_date) { 6.months.from_now.to_date.to_s }

    it { is_expected.to be_a_success }

    it 'parses to end of day' do
      expect(result.exp).to eq(Time.zone.parse(exp_date).end_of_day.to_i)
    end
  end

  context 'when exp_date is in the past' do
    let(:exp_date) { 1.day.ago.to_date.to_s }

    it { is_expected.to be_a_failure }

    it 'returns an error message' do
      expect(result.message).to eq("La date d'expiration ne peut pas être dans le passé")
    end
  end

  context 'when exp_date exceeds 18 months' do
    let(:exp_date) { (18.months.from_now + 1.day).to_date.to_s }

    it { is_expected.to be_a_failure }

    it 'returns an error message' do
      expect(result.message).to eq("La date d'expiration ne peut pas dépasser 18 mois")
    end
  end

  context 'when exp_date is exactly 18 months from now' do
    let(:exp_date) { 18.months.from_now.to_date.to_s }

    it { is_expected.to be_a_success }
  end
end
