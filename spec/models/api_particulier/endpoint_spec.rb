# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/models/endpoint'

RSpec.describe APIParticulier::Endpoint do
  let(:example_uid) { 'cnav/quotient_familial' }

  it_behaves_like 'an endpoint model', -> { 'cnav/quotient_familial' }, skip_first_element_check: true

  # Additional API Particulier specific tests
  describe '.all' do
    it 'contains only v3 endpoints' do
      expect(described_class.all.map(&:uid)).to include('cnav/quotient_familial')
      expect(described_class.all.map(&:uid)).not_to include('cnav/v2/quotient_familial_v2')
    end
  end

  describe '.find with specific endpoint' do
    subject { described_class.find(example_uid) }

    its(:path) { is_expected.to eq('/v3/dss/quotient_familial/identite') }

    its(:attributes) { is_expected.to have_key('allocataires') }
    its(:attributes) { is_expected.to have_key('adresse') }

    its(:title) { is_expected.to eq('Quotient familial CAF & MSA') }
  end
end
