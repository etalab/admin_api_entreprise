
require 'rails_helper'

RSpec.describe(User::Operation::Update) do
  let(:operation_params) do
    {
      id: user_id,
      note: 'Updated description',
      oauth_api_gouv_id: '9001'
    }
  end
  subject { described_class.call(params: operation_params) }

  context 'when user does not exist' do
    let(:user_id) { 0 }

    it 'fails' do
      expect(subject).to(be_failure)
    end

    it 'returns an error message' do
      expect(subject[:errors]).to(include("User with id `#{user_id}` does not exist."))
    end
  end

  context 'when user exists' do
    let(:user_id) do
      user = create(:user)
      user.id
    end

    it { is_expected.to(be_success) }

    describe '#note' do
      it 'is optional' do
        operation_params.delete(:note)

        expect(subject).to(be_success)
      end

      it 'can be updated' do
        updated_user = subject[:model]

        expect(updated_user.note).to(eq('Updated description'))
      end
    end

    describe '#oauth_api_gouv_id' do
      it 'is optional' do
        operation_params.delete(:oauth_api_gouv_id)

        expect(subject).to(be_success)
      end

      it 'must be an string' do
        operation_params[:oauth_api_gouv_id] = 42

        expect(subject).to(be_failure)
        expect(subject[:errors]).to(eq(oauth_api_gouv_id: ['must be a string']))
      end

      it 'can be updated' do
        updated_user = subject[:model]

        expect(updated_user.oauth_api_gouv_id).to(eq('9001'))
      end
    end
  end
end
