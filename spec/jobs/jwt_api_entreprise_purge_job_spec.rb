require 'rails_helper'

RSpec.describe JwtApiEntreprisePurgeJob do
  subject { described_class.perform_now }

  it 'calls the purge operation' do
    expect(JwtApiEntreprise::Operation::Purge).to receive(:call)

    subject
  end
end
