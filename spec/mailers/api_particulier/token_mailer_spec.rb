# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/mailers/token_mailer'

RSpec.describe APIParticulier::TokenMailer, type: :feature do
  it_behaves_like 'a token mailer', :particulier, :api_particulier_token_prolong_start_path
end
