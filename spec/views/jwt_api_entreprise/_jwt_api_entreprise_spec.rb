require 'rails_helper'

RSpec.describe 'jwt_api_entreprise/_jwt_api_entreprise.html.erb' do
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
  it { is_expected.to include(token.renewal_url) }
end
