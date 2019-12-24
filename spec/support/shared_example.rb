RSpec.shared_examples 'client user unauthorized' do |req_verb, action, req_params = {}|
  include_context 'user request'
  before { self.send(req_verb, action, params: req_params) }

  it 'returns 403' do
    expect(response.code).to eq '403'
  end

  it 'returns "Forbidden" message' do
    body = JSON.parse(response.body, symbolize_names: true)
    expect(body[:errors]).to eq 'Forbidden'
  end
end

RSpec.shared_examples :password_renewal_contract do
  let(:op_params) do
    {
      password: 'couCOU23',
      password_confirmation: 'couCOU23'
    }
  end

  subject { described_class.call(params: op_params) }

  let(:errors) { subject[:errors] }
  let(:format_error_message) { 'minimum eight characters, at least one uppercase letter, one lowercase letter and one number' }

  it 'must match confirmation' do
    op_params[:password_confirmation] = 'coucou23'
    subject

    expect(subject).to be_failure
    expect(errors[:password_confirmation]).to include('must be equal to password')
  end

  it 'is min 8 characters long' do
    op_params[:password] = op_params[:password_confirmation] = 'a' * 7

    expect(errors[:password]).to include('size cannot be less than 8')
  end

  it 'contains a lowercase letter' do
    op_params[:password] = op_params[:password_confirmation] = 'AAAAAAAAA3'

    expect(errors[:password]).to include(format_error_message)
  end

  it 'contains an uppercase letter' do
    op_params[:password] = op_params[:password_confirmation] = 'aaaaaaaaa3'

    expect(errors[:password]).to include(format_error_message)
  end

  it 'contains a number' do
    op_params[:password] = op_params[:password_confirmation] = 'AAAAAAAAAa'

    expect(errors[:password]).to include(format_error_message)
  end

  it 'accepts special characters' do
    op_params[:password] = op_params[:password_confirmation] = 'Cou-cou!123?'

    expect(errors[:password]).to be_nil
  end
end
