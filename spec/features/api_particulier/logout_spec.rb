# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/features/logout'

RSpec.describe 'log out', app: :api_particulier do
  it_behaves_like 'a logout feature', APIParticulier::SessionsController, :api_particulier_user_profile_path
end
