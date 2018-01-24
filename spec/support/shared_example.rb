RSpec.shared_examples 'unauthorized' do
  it 'returns 401' do
    expect(response.code).to eq '401'
  end

  it 'returns "Not authorized" message' do
    body = JSON.parse(response.body, symbolize_names: true)
    expect(body[:errors]).to eq 'Not authorized'
  end
end
