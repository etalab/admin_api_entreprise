require 'rails_helper'

# JWT emited by doorkeeper on user login
describe 'JWT for account data access', type: :jwt do
  let(:user) { UsersFactory.confirmed_user }
  let(:token_payload) do
    # call JWTF the way Doorkeeper does
    token = JWTF.generate(resource_owner_id: user.id)
    token_payload = extract_payload_from(token)
    token_payload
  end

  it 'contains the user UUID' do
    expect(token_payload[:uid]).to eq user.id
  end

  it 'contains the creation date timestamp' do
    creation_timestamp = token_payload[:iat]

    # giving the test 2 seconds lag security
    expect(creation_timestamp).to be_within(2).of(Time.now.to_i)
  end

  it 'is valid 4 hours' do
    creation_timestamp = token_payload[:iat]
    expiration_timestamp = token_payload[:exp]

    # giving the test 2 seconds lag security
    expect(expiration_timestamp)
      .to be_within(2).of(creation_timestamp + (4*3600))
  end
end
