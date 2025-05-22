# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/shared_examples/organizers/user/o_auth_login'

RSpec.describe APIParticulier::User::OAuthLogin, type: :organizer do
  it_behaves_like 'an oauth login organizer', 'api_particulier'
end
