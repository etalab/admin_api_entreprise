require 'rails_helper'

RSpec.describe AttestationPolicy do
  subject { described_class }

  permissions :any? do
    context 'when user doesnt have attestation scopes' do
      let(:user) { create :user }

      it { is_expected.not_to permit(user) }
    end

    context 'when user has attestation scope' do
      let(:user) { create :user, :with_jwt, scopes: ['attestations_fiscales'] }

      it { is_expected.to permit(user) }
    end
  end
end
