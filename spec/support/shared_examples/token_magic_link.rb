RSpec.shared_examples 'it creates a magic link' do
  it_behaves_like 'display alert', :success

  it 'sends the email magic link' do
    expect { subject }
      .to have_enqueued_mail(TokenMailer, :magic_link)
      .with(email, token)
  end

  describe 'the token record' do
    it 'saves a magic token' do
      subject

      expect(token.reload.magic_link_token).to match(/\A[0-9a-f]{20}\z/)
    end

    it 'saves the issuance date of the magic token' do
      creation_time = Time.zone.now
      Timecop.freeze(creation_time) do
        subject

        expect(token.reload.magic_link_issuance_date.to_i).to eq(creation_time.to_i)
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
end
