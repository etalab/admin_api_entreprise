# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/features/show_token_from_magic_link'

RSpec.describe 'show token from magic link', app: :api_particulier do
  it_behaves_like 'a show token from magic link feature', :api_particulier_token_show_magic_link_path do
    before do
      user.authorization_requests.update_all(api: 'particulier')
    end
  end
end
