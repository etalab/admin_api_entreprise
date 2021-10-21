require 'rails_helper'

RSpec.describe 'jwt_api_entreprise/_jwt_api_entreprise.html.erb', type: :view do
  let(:token) { create(:jwt_api_entreprise) }

  subject do
    render partial: 'jwt_api_entreprise', object: token
    rendered
  end

  it { is_expected.to include(token.displayed_subject) }
  it { is_expected.to include(friendly_format_from_timestamp(token.iat)) }
  it { is_expected.to include(friendly_format_from_timestamp(token.exp)) }
  it { is_expected.to include(*token.roles.pluck(:code)) }
  it { is_expected.to include(token.rehash) }

  context 'when accessed from a connected user' do
    before do
      allow_any_instance_of(UserSessionsHelper)
        .to receive(:user_signed_in?)
        .and_return(true)
    end

    it { is_expected.to include(token.renewal_url) }
    it { is_expected.to include(token.authorization_request_url) }
    it { is_expected.to include(token_create_magic_link_path(token)) }
    it { is_expected.to include(token_stats_path(token)) }
  end

  context 'when accessed via magic link' do
    it { is_expected.not_to include(token.renewal_url) }
    it { is_expected.not_to include(token.authorization_request_url) }
    it { is_expected.not_to include(token_create_magic_link_path(token)) }
  end
end
