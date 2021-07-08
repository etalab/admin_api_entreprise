require 'rails_helper'

RSpec.describe JwtApiEntreprise::Operation::CreateMagicLink do
  subject { described_class.call(params: op_params, current_user: current_user) }

  let(:op_params) do
    {
      id: jwt_id,
      email: email_address,
    }
  end

  let(:current_user) do
    JwtUser.new(uid: user_id, admin: user_admin?)
  end

  let(:end_state) { subject.event.to_h[:semantic] }

  context 'when the JwtApiEntreprise record does not exist' do
    let(:email_address) { 'whatever' }
    let(:jwt_id) { '0' }
    let(:user_id) { 'whatever' }
    let(:user_admin?) { false }

    it { is_expected.to be_failure }

    it 'ends in :not_found state' do
      expect(end_state).to eq(:not_found)
    end

    it 'does not queue any email' do
      expect { subject }
        .to_not have_enqueued_mail(JwtApiEntrepriseMailer, :magic_link)
    end
  end

  context 'when the JwtApiEntreprise record exists' do
    let!(:jwt) { create(:jwt_api_entreprise) }
    let(:jwt_id) { jwt.id }

    context 'with a valid email address' do
      let(:email_address) { 'valid@email.com' }

      shared_examples :magic_link_created do
        it { is_expected.to be_success }

        it 'queues the magic link email' do
          expect { subject }
            .to have_enqueued_mail(JwtApiEntrepriseMailer, :magic_link)
            .with(args: [email_address, jwt])
        end

        describe 'the token record' do
          it 'saves a magic token' do
            subject
            jwt.reload

            expect(jwt.magic_link_token).to match(/\A[0-9a-f]{20}\z/)
          end

          it 'saves the issuance date of the magic token' do
            creation_time = Time.zone.now
            Timecop.freeze(creation_time) do
              subject
              jwt.reload

              expect(jwt.magic_link_issuance_date.to_i).to eq(creation_time.to_i)
            end
          end
        end
      end

      context 'when the requesting user is the owner of the token' do
        let(:user_id) { jwt.user.id }
        let(:user_admin?) { false }

        it_behaves_like :magic_link_created
      end

      context 'when the requesting user is an admin' do
        let(:user_id) { 'whatever' }
        let(:user_admin?) { true }

        it_behaves_like :magic_link_created
      end

      context 'when the requesting user does not own the token' do
        let(:user_id) { '1234' }
        let(:user_admin?) { false }

        it { is_expected.to be_failure }

        it 'ends in :unauthorized state' do
          expect(end_state).to eq(:unauthorized)
        end

        it 'does not queue any email' do
          expect { subject }
            .to_not have_enqueued_mail(JwtApiEntrepriseMailer, :magic_link)
        end
      end
    end

    context 'with an invalid email address' do
      let(:email_address) { 'not an email' }
      let(:user_id) { 'whatever' }
      let(:user_admin?) { true }

      it { is_expected.to be_failure }

      it 'ends in :invalid_params state' do
        expect(end_state).to eq(:invalid_params)
      end

      it 'does not queue any email' do
        expect { subject }
          .to_not have_enqueued_mail(JwtApiEntrepriseMailer, :magic_link)
      end
    end
  end
end
