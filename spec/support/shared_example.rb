RSpec.shared_examples('client user unauthorized') do |req_verb, action, req_params = {}|
  include_context 'user request'
  before { send(req_verb, action, params: req_params) }

  it 'returns 403' do
    expect(response.code).to eq '403'
  end

  it 'returns "Forbidden" message' do
    body = JSON.parse(response.body, symbolize_names: true)
    expect(body[:errors]).to eq 'Forbidden'
  end
end
