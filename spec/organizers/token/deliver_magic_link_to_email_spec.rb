require 'rails_helper'

RSpec.describe Token::DeliverMagicLinkToEmail, type: :organizer do
  subject { described_class.call(params) }

  let(:params) do
    {
      email:,
      host:
    }
  end

  let(:new_magic_link) { MagicLink.find_by(email:) }
  let(:host) { 'entreprise.api.gouv.fr' }

  context 'with a valid email address' do
    let(:email) { 'valid@email.com' }

    it { is_expected.to be_success }

    it 'queues the magic link email' do
      expect { subject }
        .to have_enqueued_mail(APIEntreprise::TokenMailer, :magic_link)
        .with(new_magic_link)
    end

    context 'with api pariculier host' do
      let(:host) { 'particulier.api.gouv.fr' }

      it 'queues the magic link email' do
        expect { subject }
          .to have_enqueued_mail(APIParticulier::TokenMailer, :magic_link)
          .with(new_magic_link)
      end
    end

    it 'saves a magic random token' do
      subject

      expect(new_magic_link.access_token).to match(/\A[0-9a-f]{20}\z/)
    end
  end

  context 'with an email which exists in database' do
    let(:email) { create(:user).email }

    it { is_expected.to be_success }
  end

  context 'with an invalid email address' do
    let(:email) { 'not an email' }

    it { is_expected.to be_failure }

    it 'does not queue any email' do
      expect { subject }
        .not_to have_enqueued_mail(APIEntreprise::TokenMailer, :magic_link)
    end
  end
end
