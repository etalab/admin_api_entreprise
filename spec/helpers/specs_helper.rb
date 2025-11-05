module SpecsHelper
  def api_entreprise_example_uid
    'insee/unites_legales'
  end

  def api_entreprise_example_collection_uid
    'infogreffe/mandataires_sociaux'
  end

  def siret_valid
    '41816609600069'
  end

  def siren_valid
    siret_valid.first(9)
  end

  def stub_hyperping_request_operational(api)
    stub_request(:get, "https://api-#{api}.hyperping.app/api/config?hostname=api-#{api}.hyperping.app").and_return(
      status: 200,
      body: {
        globals: {
          topLevelStatus: {
            status: 'up'
          }
        }
      }.to_json
    )
  end

  def stub_hyperping_request_monitor_down(api)
    stub_request(:get, "https://api-#{api}.hyperping.app/api/config?hostname=api-#{api}.hyperping.app").and_return(
      status: 200,
      body: Rails.root.join('spec/support/hyperping_status_page_one_down.json').read
    )
  end
end
