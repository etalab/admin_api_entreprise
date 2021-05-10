require 'rails_helper'

# TODO Replace "account" naming with "session"
# JWT emited by doorkeeper on user login
RSpec.describe('JWT for account data access', type: :jwt) do
  let(:user) { create(:user) }
  let(:token_payload) do
    # call JWTF the way Doorkeeper does
    token = JWTF.generate(resource_owner_id: user.id)
    token_payload = extract_payload_from(token)
    token_payload
  end

  it 'contains the user UUID' do
    expect(token_payload[:uid]).to(eq(user.id))
  end

  it 'contains the creation date timestamp' do
    Timecop.freeze
    creation_timestamp = token_payload[:iat]

    expect(creation_timestamp).to(eq(Time.zone.now.to_i))
    Timecop.return
  end

  it 'expires in 4 hours' do
    creation_timestamp = token_payload[:iat]
    expiration_timestamp = token_payload[:exp]

    # giving the test 2 seconds lag security
    expect(expiration_timestamp)
      .to(be_within(2).of(creation_timestamp + (4*3600)))
  end
end
