# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/features/logout'

RSpec.describe 'log out', app: :api_entreprise do
  it_behaves_like 'a logout feature', APIEntreprise::SessionsController, :user_profile_path
end
