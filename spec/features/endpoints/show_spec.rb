require 'rails_helper'

RSpec.describe 'Endpoints show', type: :feature do
  let(:uid) { 'insee/entreprise' }

  let(:endpoint) { Endpoint.find(uid) }

  it 'displays basic information, with attributes data' do
    visit endpoint_path(uid: uid)

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
end
