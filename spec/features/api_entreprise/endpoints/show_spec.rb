require 'rails_helper'

RSpec.describe 'Endpoints show', app: :api_entreprise do
  let(:endpoint) { APIEntreprise::Endpoint.find(uid) }
  let(:uid) { api_entreprise_example_uid }
  let(:api_status) { 200 }

  before do
    stub_request(:get, endpoint.ping_url).to_return(status: api_status) if endpoint.ping_url

    visit endpoint_path(uid:)
  end

  it 'displays basic information, with attributes data' do
    expect(page).to have_content(endpoint.title)

    expect(page).to have_css('#property_attribute_type')

    within('#property_attribute_type') do
      expect(page).to have_content(endpoint.attributes['type']['description'])
    end
  end

  it "displays links to cas d'usage" do
    expect(page).to have_link('Marchés publics', href: cas_usage_path(uid: 'marches_publics'))
  end

  describe 'real time status' do
    context 'when endpoint is up' do
      let(:api_status) { 200 }

      it 'displays UP status' do
        expect(page).to have_css('.api-status-up')
      end
    end

    context 'when endpoint is down' do
      let(:api_status) { 502 }

      it 'displays UP status' do
        expect(page).to have_css('.api-status-down')
      end
    end
  end

  describe 'each endpoint' do
    APIEntreprise::Endpoint.all.each do |endpoint|
      it "works for #{endpoint.uid} endpoint" do
        visit endpoint_path(uid: endpoint.uid)

        expect(page).to have_css("#api_entreprise_endpoint_#{endpoint.id}")
      end
    end
  end

  describe 'provider errors' do
    context 'with an endpoint which has no custom provider error' do
      let(:uid) { 'fabrique_numerique_ministeres_sociaux/conventions_collectives' }

      it 'does not display errors part' do
        expect(page).not_to have_css('#erreurs')
      end
    end

    context 'with an endpoint which has custom provider error' do
      let(:uid) { 'urssaf/attestation_vigilance' }

      it 'displays errors part' do
        expect(page).to have_css('#erreurs')
      end
    end
  end

  describe 'actions' do
    describe 'click on example', :js do
      it 'opens modal with example' do
        click_link 'example_link'

        within('#main-modal-content') do
          expect(page).to have_content('"sigle": "DINUM"')
        end
      end

      it 'open modal with custom example' do
        visit endpoint_path(uid: api_entreprise_example_collection_uid)

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
