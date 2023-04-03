require 'rails_helper'

RSpec.describe 'Endpoints show', app: :api_particulier do
  let(:uid) { api_particulier_example_uid }

  let(:endpoint) { APIParticulier::Endpoint.find(uid) }

  it 'displays basic information, with attributes data' do
    visit endpoint_path(uid:)

    expect(page).to have_content(endpoint.title)

    expect(page).to have_css('#property_attribute_allocataires')
  end

  describe 'each endpoint' do
    APIParticulier::Endpoint.all.each do |endpoint|
      it "works for #{endpoint.uid} endpoint" do
        visit endpoint_path(uid: endpoint.uid)

        expect(page).to have_css("#api_particulier_endpoint_#{endpoint.id}")
      end
    end
  end

  describe 'actions' do
    describe 'click on example', js: true do
      it 'opens modal with example' do
        visit endpoint_path(uid:)

        click_on 'example_link'

        within('#main-modal-content') do
          expect(page).to have_content('JEAN JACQUES')
        end
      end
    end
  end
end
