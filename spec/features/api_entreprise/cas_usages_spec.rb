# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/features/cas_usages'

RSpec.describe 'Cas usages pages', app: :api_entreprise do
  it_behaves_like 'a cas usages feature', APIEntreprise

  # API Entreprise specific tests
  it 'displays icons on API lists' do
    visit cas_usage_path(uid: 'marches_publics')

    within('[@id="insee/etablissements_diffusibles"]') do
      expect(page).to have_css('.fr-icon-checkbox-circle-fill')
    end
  end
end
