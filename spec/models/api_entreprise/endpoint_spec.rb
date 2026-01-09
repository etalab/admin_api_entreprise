# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/models/endpoint'

RSpec.describe APIEntreprise::Endpoint do
  it_behaves_like 'an endpoint model', -> { 'insee/unites_legales' }

  # Additional API Entreprise specific tests
  describe '.find with collection uid' do
    subject { described_class.find(uid) }

    let(:uid) { 'infogreffe/mandataires_sociaux' }

    it { is_expected.to be_an_instance_of(described_class) }

    its(:attributes) { is_expected.to be_an_instance_of(Hash) }
    its(:attributes) { is_expected.to have_key('fonction') }

    its(:root_links) { is_expected.to be_an_instance_of(Hash) }

    its(:root_meta) { is_expected.to be_an_instance_of(Hash) }
    its(:root_meta) { is_expected.to have_key('personnes_morales_count') }

    its(:example_payload) { is_expected.to be_an_instance_of(Hash) }

    it 'has custom example' do
      expect(subject.example_payload['data']).to have_exactly(2).items
    end

    its(:collection?) { is_expected.to be true }
  end

  describe '.find with regular uid' do
    subject { described_class.find(uid) }

    let(:uid) { 'insee/unites_legales' }

    its(:path) { is_expected.to eq('/v4/insee/sirene/unites_legales/{siren}') }

    its(:perimeter) { is_expected.to be_present }
    its(:opening) { is_expected.to be_present }

    its(:attributes) { is_expected.to have_key('date_creation') }

    its(:root_links) { is_expected.to be_an_instance_of(Hash) }
    its(:root_links) { is_expected.to have_key('siege_social') }

    its(:root_meta) { is_expected.to be_an_instance_of(Hash) }
    its(:root_meta) { is_expected.to have_key('date_derniere_mise_a_jour') }

    its(:collection?) { is_expected.to be false }

    describe '#error_examples' do
      subject { described_class.find(uid).error_examples('401') }

      it { is_expected.to be_an_instance_of(Array) }

      it 'contains error payload' do
        element = subject.first

        expect(element).to be_present
        expect(element).to have_key('title')
        expect(element).to have_key('detail')
        expect(element).to have_key('code')
      end
    end
  end
end
