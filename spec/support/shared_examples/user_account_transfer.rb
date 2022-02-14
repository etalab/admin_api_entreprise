RSpec.shared_examples 'it aborts the user account transfer' do
  it_behaves_like 'display alert', :error

  it 'does not transfer any tokens' do
    user_tokens_id = user.jwt_api_entreprise.pluck(:id)
    subject

    expect(user.jwt_api_entreprise.reload.pluck(:id))
      .to contain_exactly(*user_tokens_id)
  end
end

RSpec.shared_examples 'it succeeds the user account transfer' do
  it_behaves_like 'display alert', :success

  it 'deletes the tokens from the previous account' do
    subject

    expect(user.jwt_api_entreprise).to be_empty
  end

  it 'transfer the tokens to the target account' do
    tokens_id = user.jwt_api_entreprise.pluck(:id)
    subject
    target_user = User.find_by(email: email)

    expect(target_user.jwt_api_entreprise.pluck(:id)).to include(*tokens_id)
  end
end
