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
    it 'validates scopes for API Particulier' do
      scopes = YAML.load_file(Rails.root.join('config/data/scopes/particulier.yml'))
      expect(scopes).to all have_key('code')
      expect(scopes).to all have_key('name')
    end

    it 'validates scopes for API Entreprise' do
      scopes = YAML.load_file(Rails.root.join('config/data/scopes/entreprise.yml'))
      expect(scopes).to all have_key('code')
      expect(scopes).to all have_key('name')
    end
  end
end
