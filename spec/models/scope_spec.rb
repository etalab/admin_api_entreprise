# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scope do
  it 'has valid factories' do
    expect(build(:scope)).to be_valid
  end

  describe '#valid' do
    it 'must have a valid API' do
      expect(build(:scope, api: 'wrong API')).not_to be_valid
    end
  end

  describe 'data/scopes/*.yml' do
    describe 'Scopes for API Particulier' do
      subject(:scopes) { YAML.load_file(Rails.root.join('config/data/scopes/particulier.yml')) }

      it { is_expected.to all have_key('code') }
      it { is_expected.to all have_key('name') }
      it { is_expected.to have_at_least(1).item }
    end

    describe 'Scopes for API Entreprise' do
      subject(:scopes) { YAML.load_file(Rails.root.join('config/data/scopes/entreprise.yml')) }

      it { is_expected.to all have_key('code') }
      it { is_expected.to all have_key('name') }
      it { is_expected.to have_at_least(1).item }
    end
  end
end
