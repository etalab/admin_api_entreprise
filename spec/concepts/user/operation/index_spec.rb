require 'rails_helper'

RSpec.describe(User::Operation::Index) do
  before { create_list(:user, 8) }

  let(:op_params) { {} }

  subject { described_class.call(params: op_params) }
  let(:user_list) { subject[:user_list] }

  context 'when no filters are provided' do
    it { is_expected.to(be_success) }

    it 'returns all users in database' do
      expect(user_list).to(eq(User.all))
    end
  end

  context 'when filters are provided' do
    it { is_expected.to(be_success) }

    it 'filters by :email' do
      user = User.take
      user.update(email: 'test@lol.fr')
      op_params[:email] = user.email

      expect(user_list).to(contain_exactly(user))
    end

    it 'filters by :context' do
      user = User.take
      user.update(context: 'dat context wow')
      op_params[:context] = user.context

      expect(user_list).to(contain_exactly(user))
    end

    it 'combines filters' do
      user = User.take
      user.update(email: 'test@lol.fr', context: 'lolilol')
      op_params[:email] = user.email
      op_params[:context] = user.context

      expect(user_list).to(contain_exactly(user))
    end

    it 'returns [] if no user are found' do
      op_params[:email] = 'no_user'
      op_params[:context] = 'whatami'

      expect(user_list).to(be_empty)
    end
  end
end
