require 'rails_helper'

RSpec.describe DatapassWebhooksController, type: :controller do
  describe '#create' do
    subject do
      post :create, params: params
    end

    let(:params) do
      {
        event: event,
        model_type: 'Pass',
        fired_at: Time.now.to_i,
        data: {
          pass: {
            id: 9001
          },
        }
      }
    end

    let(:headers) do
      {
        'Content-Type' => 'application/json',
        'X-Hub-Signature-256' => hub_signature,
      }
    end

    let(:event) { 'refused' }
    let(:verify_token) { Rails.application.credentials.webhook_verify_token! }

    before do
      headers.each do |key, value|
        request.headers[key] = value
      end
    end

    context 'without a valid hub signature' do
      let(:hub_signature) { "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), 'lol', params.to_json)}" }

      it 'does not call DatapassWebhook' do
        expect(DatapassWebhook).not_to receive(:call)

        subject
      end

      it 'renders 401' do
        subject

        expect(response.code).to eq('401')
      end
    end

    context 'without hub signature' do
      let(:headers) do
        {
          'Content-Type' => 'application/json',
        }
      end

      it 'does not call DatapassWebhook' do
        expect(DatapassWebhook).not_to receive(:call)

        subject
      end

      it 'tracks through Sentry the incoming payload' do
        expect(Sentry).to receive(:set_context).with(
          'DataPass webhook incoming payload',
          payload: params,
        )
        expect(Sentry).to receive(:capture_message).with(
          'DataPass Incoming Payload',
          {
            level: 'info',
          }
        )

        subject
      end

      it 'renders 401' do
        subject

        expect(response.code).to eq('401')
      end
    end

    context 'with a valid hub signature' do
      let(:hub_signature) { "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), verify_token, params.to_json)}" }

      let(:token_id) { 'token id' }

      before do
        allow(DatapassWebhook).to receive(:call).and_return(
          OpenStruct.new(
            token_id: token_id,
          )
        )
      end

      it 'calls DatapassWebhook' do
        expect(DatapassWebhook).to receive(:call)

        subject
      end

      it 'renders 200' do
        subject

        expect(response.code).to eq('200')
      end

      it 'tracks through Sentry the incoming payload' do
        expect(Sentry).to receive(:set_context).with(
          'DataPass webhook incoming payload',
          payload: params,
        )
        expect(Sentry).to receive(:capture_message).with(
          'DataPass Incoming Payload',
          {
            level: 'info',
          }
        )

        subject
      end

      context 'when event is validate_application' do
        let(:event) { 'validate_application' }

        it 'renders a json with a token id' do
          subject

          expect(JSON.parse(response.body)['token_id']).to eq(token_id)
        end
      end

      context 'when event is not validate_application' do
        let(:event) { 'whatever' }

        it 'renders an empty json' do
          subject

          expect(JSON.parse(response.body)).to eq({})
        end
      end
    end
  end
end
