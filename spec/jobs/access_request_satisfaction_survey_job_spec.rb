require 'rails_helper'

RSpec.describe AccessRequestSatisfactionSurveyJob do
  subject { described_class }

  it 'calls the operation' do
    expect(JwtAPIEntreprise::Operation::AccessRequestSatisfactionSurvey).to receive(:call)
    subject.perform_now
  end
end
