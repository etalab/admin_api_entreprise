# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/shared_examples/features/endpoints/show'

RSpec.describe 'Endpoints show', app: :api_entreprise do
  let(:api_status) { 200 }
  let(:uid) { 'insee/unites_legales' }
  # API Entreprise specific tests
  let(:endpoint) { APIEntreprise::Endpoint.find(uid) }

  before do
    stub_request(:get, endpoint.ping_url).to_return(status: api_status) if endpoint.ping_url
    visit endpoint_path(uid:)
  end

  it_behaves_like 'an endpoints show feature', APIEntreprise, 'insee/unites_legales', '"sigle": "DINUM"'

  it 'displays attributes data' do
    expect(page).to have_css('#property_attribute_type')

    within('#property_attribute_type') do
      expect(page).to have_content(endpoint.attributes['type']['description'])
    end
  end

  it "displays links to cas d'usage" do
    expect(page).to have_link('Marchés publics', href: cas_usage_path(uid: 'marches_publics'))
  end

  describe 'provider errors' do
    context 'with an endpoint which has no custom provider error' do
      let(:uid) { 'fabrique_numerique_ministeres_sociaux/conventions_collectives' }

      it 'does not display errors part' do
        expect(page).to have_no_css('#erreurs')
      end
    end

    context 'with an endpoint which has custom provider error' do
      let(:uid) { 'urssaf/attestation_vigilance' }

      it 'displays errors part' do
        expect(page).to have_css('#erreurs')
      end
    end

    context 'with an endpoint which has extra specific errors' do
      let(:uid) { 'cibtp/attestations_cotisations_conges_payes_chomage_intemperies' }

      it 'displays errors part' do
        expect(page).to have_css('#erreurs')
      end
    end
  end

  describe 'actions' do
    describe 'click on example with collection uid', :js do
      it 'open modal with custom example' do
        visit endpoint_path(uid: 'infogreffe/mandataires_sociaux')

        click_link 'example_link'

        within('#main-modal-content') do
          expect(page).to have_content('"type": "personne_morale"')
          expect(page).to have_content('"type": "personne_physique"')
        end
      end
    end

    describe 'click on cgu', :js do
      it 'opens modal with CGU content' do
        click_link 'cgu_link'

        within('#main-modal-content') do
          expect(page).to have_content('Conditions générales')
        end
      end
    end
  end
end
