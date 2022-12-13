RSpec.shared_examples 'it creates a magic link' do
  it_behaves_like 'display alert', :success

  let(:new_magic_link) { MagicLink.find_by(email:) }

  it 'saves a magic token' do
    expect { subject }.to change(MagicLink, :count).by(1)
  end

  it 'saves an expiration delay on the magic link' do
    subject

    expect(new_magic_link.expires_at).to be_within(10.seconds).of(4.hours.from_now)
  end
end

RSpec.shared_examples 'it doesnt send another magic link if one already exists' do
  context 'when the magic link is expired' do
    before { create(:magic_link, email:, expires_at: 1.day.ago) }

    it 'saves a new magic link' do
      expect { subject }.to change(MagicLink, :count).by(1)
    end
  end

  context 'when the magic link is not expired' do
    before { create(:magic_link, email:) }

    it 'does not save a new magic link' do
      expect { subject }.not_to change(MagicLink, :count)
    end
  end
end

RSpec.shared_examples 'it sends a magic link for tokens' do
  let(:new_magic_link) { MagicLink.find_by(email:) }

  it 'sends the email magic link' do
    expect { subject }
      .to have_enqueued_mail(TokenMailer, :magic_link)
      .with(new_magic_link)
  end
end

RSpec.shared_examples 'it sends a magic link for signin' do
  let(:new_magic_link) { MagicLink.find_by(email:) }

  it 'sends the email magic link' do
    expect { subject }
      .to have_enqueued_mail(UserMailer, :magic_link_signin)
      .with(new_magic_link)
  end
end

RSpec.shared_examples 'it displays a magic-link-sent confirmation and redirects' do
  it 'redirects to the login page' do
    subject

    expect(page).to have_current_path(login_path)
  end

  it 'displays a success message' do
    subject

    expect(page).to have_content(I18n.t('api_entreprise.public_token_magic_links.create.title'))
  end
end

RSpec.shared_examples 'it aborts magic link' do
  it 'does not send the magic link email' do
    expect { subject }.not_to have_enqueued_mail(TokenMailer, :magic_link)
    expect { subject }.not_to have_enqueued_mail(UserMailer, :magic_link_signin)
  end

  it 'does not create a new magic link record' do
    expect { subject }.not_to change(MagicLink, :count)
  end
end
