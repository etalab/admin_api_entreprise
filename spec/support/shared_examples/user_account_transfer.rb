RSpec.shared_examples 'it aborts the user account transfer' do
  it_behaves_like 'display alert', :error

  it 'does not transfer any tokens' do
    user_tokens_id = user.tokens.pluck(:id)
    subject

    expect(user.tokens.reload.pluck(:id))
      .to match_array(user_tokens_id)
  end
end

RSpec.shared_examples 'it succeeds the user account transfer' do
  it_behaves_like 'display alert', :success

  it 'deletes the tokens from the previous account' do
    subject

    expect(user.tokens).to be_empty
  end

  it 'transfer the tokens to the target account' do
    tokens_id = user.tokens.pluck(:id)
    subject
    target_user = User.find_by(email:)

    expect(target_user.tokens.pluck(:id)).to include(*tokens_id)
  end
end
