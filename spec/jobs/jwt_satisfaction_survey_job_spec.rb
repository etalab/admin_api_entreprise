require 'rails_helper'

RSpec.describe JwtSatisfactionSurveyJob do
  before do
    expect(JwtSatisfactionSurvey::Operation::Create).to receive(:call)
  end

  subject { described_class }

  it 'calls the operation' do
    subject.perform_now
  end
end
