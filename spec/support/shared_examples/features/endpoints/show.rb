# frozen_string_literal: true

RSpec.shared_examples 'an endpoints show feature' do |api_module, default_uid, example_content|
  let(:endpoint) { api_module::Endpoint.find(uid) }
  let(:uid) { default_uid }
  let(:api_status) { 200 }

  before do
    stub_request(:get, endpoint.ping_url).to_return(status: api_status) if endpoint.ping_url

    visit endpoint_path(uid:)
  end

  it 'displays basic information' do
    expect(page).to have_content(endpoint.title)
  end

  it 'displays link to test cases' do
    expect(page).to have_link(I18n.t("#{api_module.name.underscore}.endpoints.details.test_cases").to_s, href: endpoint.test_cases_external_url)
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

      it 'displays DOWN status' do
        expect(page).to have_css('.api-status-down')
      end
    end
  end

  describe 'each endpoint' do
    api_module::Endpoint.all.each do |single_endpoint|
      it "works for #{single_endpoint.uid} endpoint" do
        visit endpoint_path(uid: single_endpoint.uid)

        expect(page).to have_css("##{dom_id(single_endpoint)}")
      end
    end
  end

  describe 'actions' do
    describe 'click on example', :js do
      it 'opens modal with example' do
        click_link 'example_link'

        within('#main-modal-content') do
          expect(page).to have_content(example_content)
        end
      end
    end
  end
end
