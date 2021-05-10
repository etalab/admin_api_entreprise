require 'rails_helper'

RSpec.describe(Incident::Operation::Create) do
  let(:operation_params) do
    {
      title: 'Test incident',
      subtitle: 'From yesterday to tomorrow',
      description: 'I\'m the incident description.'
    }
  end
  subject { described_class.call(params: operation_params) }

  # TODO not sure about how to text this
  it 'delegates the call and validations to the Save operation'

  it 'creates a new incident' do
    expect { subject }.to(change(Incident, :count).by(1))
  end

  it 'references the new incident into the :model result field' do
    new_incindent = subject[:model]

    expect(new_incindent).to(be_persisted)
    expect(new_incindent.title).to(eq('Test incident'))
    expect(new_incindent.subtitle).to(eq('From yesterday to tomorrow'))
    expect(new_incindent.description).to(eq('I\'m the incident description.'))
  end
end
