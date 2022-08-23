require 'rails_helper'

RSpec.describe 'Endpoints show', type: :feature, app: :api_entreprise do
  let(:uid) { example_uid }

  let(:endpoint) { Endpoint.find(uid) }

  it 'displays basic information, with attributes data' do
    visit endpoint_path(uid:)

    expect(page).to have_content(endpoint.title)

    expect(page).to have_css('#property_attribute_type')

    within('#property_attribute_type') do
      expect(page).to have_content(endpoint.attributes['type']['description'])
    end
  end

  describe 'each endpoint' do
    Endpoint.all.each do |endpoint|
      it "works for #{endpoint.uid} endpoint" do
        visit endpoint_path(uid: endpoint.uid)

        expect(page).to have_content(endpoint.title)
      end
    end
  end

  describe 'provider errors' do
    before do
      visit endpoint_path(uid:)
    end

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
    describe 'click on example', js: true do
      it 'opens modal with example' do
        visit endpoint_path(uid:)

        click_on 'example_link'

        within('#main-modal-content') do
          expect(page).to have_content('"sigle": "DINUM"')
        end
      end

      it 'open modal with custom example' do
        visit endpoint_path(uid: example_collection_uid)

        click_on 'example_link'

        within('#main-modal-content') do
          expect(page).to have_content('"type": "personne_morale"')
          expect(page).to have_content('"type": "personne_physique"')
        end
      end
    end

    describe 'click on cgu', js: true do
      it 'opens modal with CGU content' do
        visit endpoint_path(uid:)

        click_on 'cgu_link'

        within('#main-modal-content') do
          expect(page).to have_content('Conditions générales')
        end
      end
    end
  end
end
