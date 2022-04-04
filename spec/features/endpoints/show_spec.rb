require 'rails_helper'

RSpec.describe 'Endpoints show', type: :feature do
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

  describe 'actions' do
    describe 'click on example', js: true do
      it 'opens modal with example' do
        visit endpoint_path(uid:)

        click_on 'example_link'

        within('#main-modal-content') do
          expect(page).to have_content('"type": "entreprise"')
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
          expect(page).to have_content('Conditions Générales')
        end
      end
    end
  end
end
