require 'rails_helper'

describe User, type: :model do
  let(:user) { create(:user) }

  it 'is valid' do
    expect(user).to be_valid
    expect(user).to be_persisted
  end

  describe '#email' do
    it 'is required' do
      user.email = ''
      user.valid?
      expect(user.errors[:email].size).to eq 2
    end

    it 'has a valid format' do
      user.email = 'not.an.email'
      user.valid?
      expect(user.errors[:email].size).to eq 1
    end
  end

  describe '#roles association' do
    let(:user_with_roles) { create(:user_with_roles) }

    it 'has many roles' do
      expect(user_with_roles.roles.size).to be >= 1
    end

    it 'roles can be added' do
      role = create :role
      user_with_roles.roles << role
      expect(user_with_roles.roles.size).to eq 4
    end

    it 'keeps older associated roles on destroy' do
      roles_id = user_with_roles.role_ids
      user_with_roles.destroy
      expect(Role.where id: roles_id).to be
    end
  end

  describe '#token' do
    it 'is set before save' do
      new_user = build :user, email: 'new@record.gg', token: nil
      new_user.save
      expect(new_user.token).to be_a String
    end

    it 'contains access authorization based on user roles' do
      user = create :user # :user factory has no roles
      user.roles << create(:role)
      user.set_token
      user.save
      user_scope = AccessToken.get_scope user.token
      expect(user_scope).to eq user.roles.map(&:name)
    end
  end
end
