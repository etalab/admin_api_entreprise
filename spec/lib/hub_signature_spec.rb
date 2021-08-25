# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HubSignature do
  describe '#valid?' do
    subject { described_class.new(value, body) }

    let(:verify_token) { Rails.application.credentials.webhook_verify_token! }

    context 'without body nor value' do
      let(:body) { nil }
      let(:value) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'with a value well formed' do
      let(:value) { "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), verify_token, payload)}" }
      let(:payload) { 'whatever' }

      context 'when body is the payload used to create the HMAC signature' do
        let(:body) { payload }

        it { is_expected.to be_valid }
      end

      context 'when body is not the payload used to create the HMAC signature' do
        let(:body) { 'whatever else' }

        it { is_expected.not_to be_valid }
      end
    end
  end
end

