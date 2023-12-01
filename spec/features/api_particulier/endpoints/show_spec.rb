require 'rails_helper'

RSpec.describe 'Endpoints show', app: :api_particulier do
  let(:endpoint) { APIParticulier::Endpoint.find(uid) }
  let(:uid) { api_particulier_example_uid }
  let(:api_status) { 200 }

  before do
    stub_request(:get, endpoint.ping_url).to_return(status: api_status) if endpoint.ping_url

    visit endpoint_path(uid:)
  end

  it 'displays basic information, with attributes data' do
    expect(page).to have_content(endpoint.title)

    expect(page).to have_css('#property_attribute_allocataires')
  end

  it "displays cas d'usage" do
    expect(page).to have_content('Tarification sociale et solidaire des transports')
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
    APIParticulier::Endpoint.all.each do |endpoint|
      it "works for #{endpoint.uid} endpoint" do
        visit endpoint_path(uid: endpoint.uid)

        expect(page).to have_css("#api_particulier_endpoint_#{endpoint.id}")
      end
    end
  end

  describe 'actions' do
    describe 'click on example', :js do
      it 'opens modal with example' do
        click_link 'example_link'

        within('#main-modal-content') do
          expect(page).to have_content('JEAN JACQUES')
        end
      end
    end
  end
end
