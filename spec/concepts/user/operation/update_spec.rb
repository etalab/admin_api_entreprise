require 'rails_helper'

describe User::Operation::Update do
  let(:operation_params) do
    {
      id: user_id,
      note: 'Updated description'
    }
  end
  subject { described_class.call(params: operation_params) }

  context 'when user does not exist' do
    let(:user_id) { 0 }

    it 'fails' do
      expect(subject).to be_failure
    end

    it 'returns an error message' do
      expect(subject[:errors]).to include("User with id `#{user_id}` does not exist.")
    end
  end

  context 'when user exists' do
    let(:user_id) do
      user = create(:user)
      user.id
    end

    it { is_expected.to be_success }

    describe '#note' do
      it 'is optional' do
        operation_params.delete(:note)

        expect(subject).to be_success
      end

      it 'can be update' do
        updated_user = subject[:model]

        expect(updated_user.note).to eq('Updated description')
      end
    end
  end
end
