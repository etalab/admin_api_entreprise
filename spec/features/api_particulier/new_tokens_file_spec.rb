RSpec.describe 'API Particulier: new tokens button download on profile page', app: :api_particulier do
  let(:user) { create(:user) }
  let(:valid_file_path) { Rails.root.join('token_export', "demarche_#{user.email}.csv") }

  before do
    login_as(user)
  end

  context 'when there is a file to download' do
    before do
      File.write(valid_file_path, 'whatever')
    end

    after do
      File.delete(valid_file_path)
    end

    it 'displays a button to download the file' do
      visit api_particulier_user_profile_path

      expect(page).to have_css('a#download_new_tokens_file')
    end
  end

  context 'when there is no file to download' do
    it 'does not display a button to download the file' do
      visit api_particulier_user_profile_path

      expect(page).not_to have_css('a#download_new_tokens_file')
    end
  end
end
