require 'rails_helper'

RSpec.describe 'Endpoints index', app: :api_entreprise do
  let(:sample_endpoint) { APIEntreprise::Endpoint.all.first }

  it 'displays endpoints with basic info and link to show' do
    visit endpoints_path

    expect(page).to have_css('.endpoint-card', count: APIEntreprise::Endpoint.all.reject(&:deprecated?).count)
    expect(page).to have_css("##{dom_id(sample_endpoint)}")

    within("##{dom_id(sample_endpoint)}") do
      expect(page).to have_content(sample_endpoint.title)

      expect(page).to have_link('', href: endpoint_path(uid: sample_endpoint.uid))
    end
  end
end
