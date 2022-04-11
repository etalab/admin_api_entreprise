require 'rails_helper'

RSpec.describe AttestationPolicy do
  subject { described_class }

  permissions :any? do
    context 'when user doesnt have attestation roles' do
      let(:user) { create :user }

      it { is_expected.not_to permit(user) }
    end

    context 'when user has attestation role' do
      let(:user) { create :user, :with_jwt, roles: ['attestations_fiscales'] }

      it { is_expected.to permit(user) }
    end
  end
end
