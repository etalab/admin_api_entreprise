# frozen_string_literal: true

RSpec.shared_examples 'an endpoints index feature' do |api_module|
  let(:endpoints_class) { api_module::Endpoint }
  let(:sample_endpoint) do
    endpoints = endpoints_class.all
    endpoints = endpoints.reject(&:deprecated?) if endpoints.first.respond_to?(:deprecated?)
    endpoints.first
  end

  it 'displays endpoints with basic info and link to show' do
    visit endpoints_path

    endpoint_count = if endpoints_class.all.first.respond_to?(:deprecated?)
                       endpoints_class.all.reject(&:deprecated?).count
                     else
                       endpoints_class.all.count
                     end

    expect(page).to have_css('.endpoint-card', count: endpoint_count)
    expect(page).to have_css("##{dom_id(sample_endpoint)}")

    within("##{dom_id(sample_endpoint)}") do
      expect(page).to have_content(sample_endpoint.title)
      expect(page).to have_link('', href: endpoint_path(uid: sample_endpoint.uid))
    end
  end
end
