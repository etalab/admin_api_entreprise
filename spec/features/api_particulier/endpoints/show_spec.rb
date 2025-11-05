# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/shared_examples/features/endpoints/show'

RSpec.describe 'Endpoints show', app: :api_particulier do
  let(:api_status) { 200 }
  let(:uid) { 'cnav/quotient_familial' }
  # API Particulier specific tests
  let(:endpoint) { APIParticulier::Endpoint.find(uid) }

  before do
    stub_hyperping_request_operational('particulier')
    stub_request(:get, endpoint.ping_url).to_return(status: api_status) if endpoint.ping_url
    visit endpoint_path(uid:)
  end

  it_behaves_like 'an endpoints show feature', APIParticulier, 'cnav/quotient_familial', 'JEAN JACQUES'

  it 'displays attributes data' do
    expect(page).to have_css('#property_attribute_allocataires')
  end

  it "displays cas d'usage" do
    expect(page).to have_content('Tarification cantine')
  end

  describe 'each endpoint V2' do
    APIParticulier::EndpointV2.all.each do |single_endpoint|
      it "works for #{single_endpoint.uid} endpoint" do
        visit endpoint_path(uid: single_endpoint.uid)

        expect(page).to have_css("##{dom_id(single_endpoint)}")
      end
    end
  end
end
