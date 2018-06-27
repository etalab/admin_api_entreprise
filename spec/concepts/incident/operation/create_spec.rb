require 'rails_helper'

describe Incident::Create do
  let(:operation_params) do
    {
      title: 'Test incident',
      subtitle: 'From yesterday to tomorrow',
      description: 'I\'m the incident description.'
    }
  end
  subject { described_class.call(params: operation_params) }
  let(:errors) { subject['result.contract.default'].errors[field_name] }

  context 'when params are valid' do
    it { is_expected.to be_success }

    it 'saves the new incident' do
      new_incident = subject[:model]

      expect(new_incident).to be_persisted
      expect(new_incident.title).to eq(operation_params[:title])
      expect(new_incident.subtitle).to eq(operation_params[:subtitle])
      expect(new_incident.description).to eq(operation_params[:description])
    end
  end

  context 'when params are invalid' do
    describe '#title' do
      let(:field_name) { :title }

      it 'is required' do
        operation_params.delete(:title)

        expect(subject).to be_failure
        expect(errors).to include 'must be filled'
      end

      it 'is max 128 characters long' do
        operation_params[:title] = 'a' * 129

        expect(subject).to be_failure
        expect(errors).to include 'size cannot be greater than 128'
      end
    end

    describe '#subtitle' do
      let(:field_name) { :subtitle }

      it 'is required' do
        operation_params.delete(:subtitle)

        expect(subject).to be_failure
        expect(errors).to include 'must be filled'
      end

      it 'is max 128 characters long' do
        operation_params[:subtitle] = 'a' * 129

        expect(subject).to be_failure
        expect(errors).to include 'size cannot be greater than 128'
      end
    end

    describe '#description' do
      let(:field_name) { :description }

      it 'is required' do
        operation_params.delete(:description)

        expect(subject).to be_failure
        expect(errors).to include 'must be filled'
      end
    end
  end
end
