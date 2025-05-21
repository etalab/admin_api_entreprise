# frozen_string_literal: true

RSpec.shared_examples 'an endpoint model' do |uid_method, opts = {}|
  let(:uid_method) { uid_method || method(:api_entreprise_example_uid) }
  let(:default_uid) { uid_method.call }

  describe '.all' do
    subject { described_class.all }

    it { is_expected.to be_an_instance_of(Array) }

    unless opts[:skip_first_element_check]
      describe 'an element' do
        subject { described_class.all.first }

        it { is_expected.to be_an_instance_of(described_class) }
      end
    end
  end

  describe '.find' do
    subject { described_class.find(uid) }

    context 'with valid uid' do
      let(:uid) { default_uid }

      it { is_expected.to be_an_instance_of(described_class) }

      its(:uid) { is_expected.to eq(uid) }
      its(:providers) { is_expected.to be_an_instance_of(Array) }
      its(:attributes) { is_expected.to be_an_instance_of(Hash) }
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

  describe '#test_cases_external_url' do
    subject { described_class.find(default_uid).test_cases_external_url }

    it { is_expected.to match(%r{https://github.com/etalab/siade_staging_data/tree/develop/payloads/}) }
  end

  describe '#redoc_anchor' do
    subject { described_class.find(default_uid).redoc_anchor }

    it { is_expected.to match(%r{tag/.*/paths/.*}) }
  end
end
