require 'rails_helper'

describe JwtUser, type: :jwt do
  let(:token_payload) do
    # call JWTF the way Doorkeeper does
    token = JWTF.generate(resource_owner_id: user_id)
    token_payload = extract_payload_from(token)
    token_payload
  end
  subject { described_class.new(token_payload) }

  context 'when the user is an admin' do
    let(:user_id) do
      create(:user, id: AuthenticationHelper::ADMIN_UID)
      AuthenticationHelper::ADMIN_UID
    end

    its(:admin?) { is_expected.to eq(true) }
  end

  context 'when the user can manage roles' do
    let(:user_id) do
      user = create(:user_with_roles)
      user.id
    end

    its(:manage_token?) { is_expected.to eq(true) }
  end

  context 'when the user as no rights' do
    let(:user_id) do
      user = create(:confirmed_user)
      user.id
    end

    its(:admin?) { is_expected.to eq(false) }
    its(:manage_token?) { is_expected.to eq(false) }
  end
end
