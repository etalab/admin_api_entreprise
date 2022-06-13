RSpec.shared_examples 'it displays user owned token' do
  let(:example_token) { user.tokens.take }

  it 'lists the user\'s active tokens' do
    subject

    user.tokens.each do |token|
      expect(page).to have_css("input[value='#{token.rehash}']")
    end
  end

  it 'displays tokens intitule' do
    subject

    expect(page).to have_content(example_token.intitule)
  end

  it 'displays tokens creation date' do
    subject

    expect(page).to have_content(friendly_format_from_timestamp(example_token.iat))
  end

  it 'displays tokens expiration date' do
    subject

    expect(page).to have_content(friendly_format_from_timestamp(example_token.exp))
  end

  it 'has a button to copy active tokens hash to clipboard' do
    subject

    user.tokens.each do |token|
      expect(page).to have_css("##{dom_id(token, :copy_button)}")
    end
  end

  it 'displays tokens access scopes' do
    token = create(:token, :with_scopes, user:)
    scopes = token.scopes.pluck(:code)
    subject

    expect(page).to have_content(*scopes)
  end

  it 'has a button to create a magic link' do
    subject

    user.tokens.each do |token|
      expect(page).to have_button(dom_id(token, :modal_button))
    end
  end

  it 'has a link for token renewal' do
    subject

    user.tokens.each do |token|
      expect(page).to have_link(dom_id(token, :renew))
    end
  end

  it 'has a link to authorization request' do
    subject

    user.tokens.each do |token|
      expect(page).to have_link(href: token.authorization_request_url)
    end
  end

  it 'has a link to access token stats' do
    subject

    user.tokens.each do |token|
      expect(page).to have_link(href: token_stats_path(token))
    end
  end

  it 'does not list other users tokens' do
    another_user = create(:user, :with_token)
    subject

    another_user.tokens.each do |token|
      expect(page).not_to have_css("input[value='#{token.rehash}']")
    end
  end

  it 'does not display expired tokens' do
    expired_token = create(:token, :expired)
    subject

    expect(page).not_to have_css("input[value='#{expired_token.rehash}']")
  end
end
