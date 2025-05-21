require 'rails_helper'

RSpec.shared_examples 'a user profile feature' do |options = {}|
  # Extract required options
  user_profile_path_helper = options[:user_profile_path_helper] || :user_profile_path
  login_path_helper = options[:login_path_helper] || :login_path
  check_user_info = options[:check_user_info].nil? || options[:check_user_info]

  subject(:go_to_profile) { visit send(user_profile_path_helper) }

  let(:user) do
    if options[:with_token]
      create(:user, :with_token)
    else
      create(:user)
    end
  end

  context 'when user is not authenticated' do
    it 'redirects to the login' do
      go_to_profile

      expect(page).to have_current_path(send(login_path_helper), ignore_query: true)
    end
  end

  if check_user_info
    context 'when the user is authenticated' do
      before do
        login_as(user)
      end

      it 'displays the user infos' do
        go_to_profile

        expect(page).to have_content(user.email)
      end
    end
  end
end
