require 'rails_helper'

describe JwtUser do
  describe '#admin?' do
    it 'returns true for an admin' do
      jwt_user = JwtUser.new('bacb9bbc-f208-4b23-a176-67504d4920dd')
      expect(jwt_user).to be_admin
    end

    it 'returns false for a client user' do
      user = UsersFactory.confirmed_user
      jwt_user = JwtUser.new(user.id)
      expect(jwt_user).to_not be_admin
    end
  end
end
