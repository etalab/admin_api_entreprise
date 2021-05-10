require 'rails_helper'

RSpec.describe(Incident::Operation::Update) do
  let(:operation_params) do
    {
      id: incident_id,
      title: 'Updated title',
      subtitle: 'Updated subtitle',
      description: 'Updated description'
    }
  end
  subject { described_class.call(params: operation_params) }

  context 'when incident does not exist' do
    let(:incident_id) { 0 }

    it 'fails' do
      expect(subject).to(be_failure)
    end

    it 'returns an error message' do
      expect(subject[:errors]).to(include("Incident with id `#{incident_id}` does not exist."))
    end
  end

  context 'when incident exists' do
    let(:incident_id) do
      incident = create(:incident)
      incident.id
    end

    # TODO not sure about how to text this
    it 'delegates the call and validations to the Save operation'

    it 'references the updated incident into the :model result field' do
      updated_incident = subject[:model]

      expect(updated_incident.title).to(eq('Updated title'))
      expect(updated_incident.subtitle).to(eq('Updated subtitle'))
      expect(updated_incident.description).to(eq('Updated description'))
    end
  end
end
