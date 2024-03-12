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

RSpec.shared_examples 'it aborts magic link' do |mailer_klass|
  it 'does not send magic link email' do
    expect { subject }.not_to have_enqueued_mail(mailer_klass, :magic_link)
  end

  it 'does not create a new magic link record' do
    expect { subject }.not_to change(MagicLink, :count)
  end
end
