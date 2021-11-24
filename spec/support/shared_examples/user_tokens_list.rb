RSpec.shared_examples :it_displays_user_owned_token do
  it 'lists the user\'s active tokens' do
    subject

    user.jwt_api_entreprise.each do |jwt|
      expect(page).to have_css("input[value='#{jwt.rehash}']")
    end
  end

  it 'has a button to copy active tokens hash to clipboard' do
    subject

    user.jwt_api_entreprise.each do |jwt|
      expect(page).to have_css("##{dom_id(jwt, :copy_button)}")
    end
  end

  it 'has a button to create a magic link' do
    subject

    user.jwt_api_entreprise.each do |jwt|
      expect(page).to have_button(dom_id(jwt, :modal_button))
    end
  end

  it 'has a link to access token stats' do
    subject

    user.jwt_api_entreprise.each do |jwt|
      expect(page).to have_link(href: token_stats_path(jwt))
    end
  end

  it 'does not list other users tokens' do
    another_user = create(:user, :with_jwt)
    subject

    another_user.jwt_api_entreprise.each do |jwt|
      expect(page).not_to have_css("input[value='#{jwt.rehash}']")
    end
  end

  it 'does not display expired tokens' do
    expired_jwt = create(:jwt_api_entreprise, :expired)
    subject

    expect(page).not_to have_css("input[value='#{expired_jwt.rehash}']")
  end
end
