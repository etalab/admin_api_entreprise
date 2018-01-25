RSpec.shared_examples 'client user unauthorized' do |req_verb, action, req_params = {}|
  include_context 'user request'
  before { self.send(req_verb, action, params: req_params) }

  it 'returns 401' do
    expect(response.code).to eq '401'
  end

  it 'returns "Not authorized" message' do
    body = JSON.parse(response.body, symbolize_names: true)
    expect(body[:errors]).to eq 'Not authorized'
  end
end
