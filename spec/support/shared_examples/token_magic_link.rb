RSpec.shared_examples 'it creates a magic link' do
  it_behaves_like 'display alert', :success

  let(:new_magic_link) { MagicLink.find_by(email:) }

  it 'sends the email magic link' do
    expect { subject }
      .to have_enqueued_mail(TokenMailer, :magic_link)
      .with(new_magic_link)
  end

  describe 'new magic link' do
    it 'saves a magic token' do
      expect { subject }.to change(MagicLink, :count).by(1)
    end

    it 'saves an expiration delay on the magic link' do
      subject

      expect(new_magic_link.expires_at).to be_within(10.seconds).of(4.hours.from_now)
    end

    it 'saves the token_id in the magic link' do
      subject

      expect(new_magic_link.token).to eq(token)
    end
  end
end

RSpec.shared_examples 'it aborts magic link' do
  it_behaves_like 'display alert', :error

  it 'does not send the magic link email' do
    expect { subject }
      .not_to have_enqueued_mail(TokenMailer, :magic_link)
  end

  it 'does not create a new magic link record' do
    expect { subject }.not_to change(MagicLink, :count)
  end
end
