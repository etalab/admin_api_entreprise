require 'rails_helper'

RSpec.describe(Incident::Operation::Save) do
  let(:operation_params) do
    {
      title: 'Test incident',
      subtitle: 'From yesterday to tomorrow',
      description: 'I\'m the incident description.'
    }
  end
  let(:incident_record) { nil }
  subject { described_class.call(params: operation_params, model: incident_record) }

  context 'when no incident record is present in params' do
    it 'saves a new incident into the database' do
      expect { subject }.to(change(Incident, :count).by(1))
      expect(subject).to(be_success)
    end
  end

  context 'when an existing incident is present in params' do
    let(:incident_record) { create(:incident) }

    it 'updates the record' do
      subject
      incident_record.reload

      expect(incident_record.title).to(eq('Test incident'))
      expect(incident_record.subtitle).to(eq('From yesterday to tomorrow'))
      expect(incident_record.description).to(eq('I\'m the incident description.'))
    end
  end

  describe 'params contract' do
    let(:errors) { subject['result.contract.default'].errors[field_name] }

    describe '#title' do
      let(:field_name) { :title }

      it 'is required' do
        operation_params.delete(:title)

        expect(subject).to(be_failure)
        expect(errors).to(include('must be filled'))
      end

      it 'is max 128 characters long' do
        operation_params[:title] = 'a' * 129

        expect(subject).to(be_failure)
        expect(errors).to(include('size cannot be greater than 128'))
      end
    end

    describe '#subtitle' do
      let(:field_name) { :subtitle }

      it 'is required' do
        operation_params.delete(:subtitle)

        expect(subject).to(be_failure)
        expect(errors).to(include('must be filled'))
      end

      it 'is max 128 characters long' do
        operation_params[:subtitle] = 'a' * 129

        expect(subject).to(be_failure)
        expect(errors).to(include('size cannot be greater than 128'))
      end
    end

    describe '#description' do
      let(:field_name) { :description }

      it 'is required' do
        operation_params.delete(:description)

        expect(subject).to(be_failure)
        expect(errors).to(include('must be filled'))
      end
    end
  end
end
