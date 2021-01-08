require 'rails_helper'

describe User::Operation::TransferOwnership do
  let(:end_state) { subject.event.to_h[:semantic] }

  subject { described_class.call(params: op_params) }

  context 'when the currrent owner does not exists' do
    let(:op_params) do
      {
        id: 'much_id',
        new_owner_email: 'whatever'
      }
    end

    it { is_expected.to be_failure }

    it 'ends in :not_found state' do
      expect(end_state).to eq(:not_found)
    end
  end

  context 'when the current owner exists' do
    let(:old_owner) { create(:user, :with_jwt) }
    let(:op_params) do
      {
        id: old_owner.id,
        new_owner_email: new_owner_email
      }
    end

    context 'when the new owner is already a user' do
      let(:new_owner_email) { 'already@known.com' }
      let!(:new_owner) { create(:user, email: new_owner_email) }

      it { is_expected.to be_success }

      it 'gives the token ownership to the new user' do
        transfered_jwt_ids = old_owner.jwt_api_entreprise_ids
        subject

        expect(new_owner.jwt_api_entreprise_ids).to include(*transfered_jwt_ids)
      end

      it 'removes token ownership to the old user' do
        subject

        expect(old_owner.jwt_api_entreprise).to be_empty
      end

      it 'sends a notification email' do
        expect(UserMailer).to receive(:transfer_ownership)
          .and_call_original

        subject
      end
    end

    context 'when the owner is unknown' do
      let(:new_owner_email) { 'not@known.com' }

      it { is_expected.to be_success }

      it 'gives the token ownership to the new user' do
        transfered_jwt_ids = old_owner.jwt_api_entreprise_ids
        subject
        new_owner = User.find_by_email(new_owner_email)

        expect(new_owner.jwt_api_entreprise_ids).to include(*transfered_jwt_ids)
      end

      it 'removes token ownership to the old user' do
        subject

        expect(old_owner.jwt_api_entreprise).to be_empty
      end

      it 'sends a notification email for account creation' do
        expect(UserMailer).to receive(:transfer_ownership)
          .and_call_original

        subject
      end

      it 'creates a ghost user' do
        subject
        new_owner = User.find_by_email(new_owner_email)

        expect(new_owner).to have_attributes({
          email: new_owner_email,
          context: old_owner.context,
          oauth_api_gouv_id: nil,
          persisted?: true
        })
      end

      describe 'validation contract' do
        describe ':new_owner_email' do
          let(:errors) do
            subject['result.contract.default'].errors[:new_owner_email]
          end

          it 'is required' do
            op_params[:new_owner_email] = ''

            expect(errors).to include 'must be filled'
          end

          it 'has an email format' do
            op_params[:new_owner_email] = 'verymail'

            expect(errors).to include 'is in invalid format'
          end

          it 'is failure' do
            op_params[:new_owner_email] = ''

            expect(subject).to be_failure
            expect(end_state).to eq(:invalid_params)
          end
        end
      end
    end
  end
end
