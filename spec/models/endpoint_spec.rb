require 'rails_helper'

RSpec.describe Endpoint, type: :model do
  describe '.all' do
    subject { described_class.all }

    it { is_expected.to be_an_instance_of(Array) }

    describe 'an element' do
      subject { described_class.all.first }

      it { is_expected.to be_an_instance_of(described_class) }
    end
  end

  describe '.find' do
    subject { described_class.find(uid) }

    context 'with valid uid' do
      let(:uid) { example_uid }

      it { is_expected.to be_an_instance_of(described_class) }

      its(:uid) { is_expected.to eq(uid) }
      its(:path) { is_expected.to eq('/v3/insee/sirene/unites_legales/{siren}') }

      its(:providers) { is_expected.to be_an_instance_of(Array) }
      its(:perimeter) { is_expected.to be_present }
      its(:opening) { is_expected.to be_present }

      its(:attributes) { is_expected.to be_an_instance_of(Hash) }
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

    context 'with collection uid' do
      let(:uid) { example_collection_uid }

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

    context 'with invalid uid' do
      let(:uid) { 'whatever' }

      it 'raises a record found error' do
        expect {
          subject
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
