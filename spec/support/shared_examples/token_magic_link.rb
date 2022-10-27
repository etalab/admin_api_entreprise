RSpec.shared_examples 'it creates a magic link' do
  it_behaves_like 'display alert', :success

  it 'sends the email magic link' do
    expect { subject }
      .to have_enqueued_mail(TokenMailer, :magic_link)
      .with(an_instance_of(MagicLink))
  end

  describe 'new magic link' do
    it 'saves a magic token' do
      expect { subject }.to change(MagicLink, :count).by(1)
    end

    it 'saves the issuance date of the magic token' do
      creation_time = Time.zone.now
      Timecop.freeze(creation_time) do
        subject

        expect(new_magic_link.created_at.to_i).to eq(creation_time.to_i)
      end
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
