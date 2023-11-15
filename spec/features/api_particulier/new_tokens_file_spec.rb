RSpec.describe 'API Particulier: new tokens button download on profile page', app: :api_particulier do
  let(:user) { create(:user) }

  let!(:authorization_request) do
    create(
      :authorization_request,
      :with_demandeur,
      demandeur: user,
      status: 'validated'
    )
  end

  before do
    login_as(user)
  end

  context 'when there is a file to download' do
    let!(:token) do
      create(
        :token,
        id: '22222222-2222-2222-2222-222222222220',
        extra_info: { emails: [user.email] },
        authorization_request:
      )
    end

    it 'displays a button to download the file' do
      visit api_particulier_user_profile_path

      expect(page).to have_css('a#download_new_tokens_file')
    end
  end

  context 'when there is no file to download' do
    let!(:token) do
      create(
        :token,
        id: '22222222-2222-2222-2222-222222222220',
        extra_info: { emails: ['watever.wherever@witness.forever'] },
        authorization_request:
      )
    end

    it 'does not display a button to download the file' do
      visit api_particulier_user_profile_path

      expect(page).not_to have_css('a#download_new_tokens_file')
    end
  end
end
