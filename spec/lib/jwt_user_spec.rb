require 'rails_helper'

RSpec.describe(JwtUser, type: :jwt) do
  let(:token_payload) do
    # call JWTF the way Doorkeeper does
    token = JWTF.generate(resource_owner_id: user_id)
    token_payload = extract_payload_from(token)
    token_payload
  end
  subject { described_class.new(token_payload) }

  context 'when the user is an admin' do
    let(:user_id) do
      admin = create(:user, :admin)
      admin.id
    end

    its(:admin?) { is_expected.to(eq(true)) }
  end
end
