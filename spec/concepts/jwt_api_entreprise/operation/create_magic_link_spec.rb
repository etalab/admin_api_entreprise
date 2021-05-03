require 'rails_helper'

RSpec.describe JwtApiEntreprise::Operation::CreateMagicLink do
  subject { described_class.call(params: op_params) }

  let(:op_params) do
    {
      id: jwt_id,
      email: email_address,
    }
  end

  let(:end_state) { subject.event.to_h[:semantic] }

  context 'when the JwtApiEntreprise record does not exist' do
    let(:email_address) { 'whatever' }
    let(:jwt_id) { '0' }

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

            expect(jwt.magic_link_issuance_date).to eq(creation_time)
          end
        end
      end
    end

    context 'with an invalid email address' do
      let(:email_address) { 'not an email' }

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
