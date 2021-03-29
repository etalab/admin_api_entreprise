require 'rails_helper'

RSpec.describe AccessRequestSatisfactionSurveyJob do
  before do
    expect(JwtApiEntreprise::Operation::AccessRequestSatisfactionSurvey).to receive(:call)
  end

  subject { described_class }

  it 'calls the operation' do
    subject.perform_now
  end
end
