require 'rails_helper'

RSpec.describe Token::DeliverMagicLinkToEmail, type: :organizer do
  subject { described_class.call(params) }

  let(:token) { create(:token) }
  let(:params) do
    {
      token:,
      email:
    }
  end

  context 'with a valid email address' do
    let(:email) { 'valid@email.com' }

    it { is_expected.to be_success }

    it 'queues the magic link email' do
      expect { subject }
        .to have_enqueued_mail(TokenMailer, :magic_link)
        .with(email, token)
    end

    it 'saves a magic token' do
      subject
      token.reload

      expect(token.magic_link_token).to match(/\A[0-9a-f]{20}\z/)
    end

    it 'saves the issuance date of the magic token' do
      creation_time = Time.zone.now
      Timecop.freeze(creation_time) do
        subject
        token.reload

        expect(token.magic_link_issuance_date.to_i).to eq(creation_time.to_i)
      end
    end
  end

  context 'with an invalid email address' do
    let(:email) { 'not an email' }

    it { is_expected.to be_failure }

    it 'does not queue any email' do
      expect { subject }
        .not_to have_enqueued_mail(TokenMailer, :magic_link)
    end
  end
end
