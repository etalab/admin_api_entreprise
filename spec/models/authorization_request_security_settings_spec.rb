require 'rails_helper'

RSpec.describe AuthorizationRequestSecuritySettings do
  it 'has valid factory' do
    expect(build(:authorization_request_security_settings)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:authorization_request) }
  end

  describe 'validations' do
    describe 'rate_limit_per_minute' do
      it 'allows nil' do
        settings = build(:authorization_request_security_settings, rate_limit_per_minute: nil)
        expect(settings).to be_valid
      end

      it 'allows positive integers' do
        settings = build(:authorization_request_security_settings, rate_limit_per_minute: 100)
        expect(settings).to be_valid
      end

      it 'rejects zero' do
        settings = build(:authorization_request_security_settings, rate_limit_per_minute: 0)
        expect(settings).not_to be_valid
        expect(settings.errors[:rate_limit_per_minute]).to be_present
      end

      it 'rejects negative values' do
        settings = build(:authorization_request_security_settings, rate_limit_per_minute: -10)
        expect(settings).not_to be_valid
        expect(settings.errors[:rate_limit_per_minute]).to be_present
      end
    end

    describe 'allowed_ips' do
      it 'allows empty array' do
        settings = build(:authorization_request_security_settings, allowed_ips: [])
        expect(settings).to be_valid
      end

      it 'allows valid IPv4 addresses' do
        settings = build(:authorization_request_security_settings, allowed_ips: ['192.168.1.1', '10.0.0.1'])
        expect(settings).to be_valid
      end

      it 'allows valid IPv4 CIDR notation' do
        settings = build(:authorization_request_security_settings, allowed_ips: ['192.168.1.0/24', '10.0.0.0/8'])
        expect(settings).to be_valid
      end

      it 'allows valid IPv6 addresses' do
        settings = build(:authorization_request_security_settings, allowed_ips: ['2001:db8::1', '::1'])
        expect(settings).to be_valid
      end

      it 'allows valid IPv6 CIDR notation' do
        settings = build(:authorization_request_security_settings, allowed_ips: ['2001:db8::/32'])
        expect(settings).to be_valid
      end

      it 'allows mixed IPv4 and IPv6' do
        settings = build(:authorization_request_security_settings, allowed_ips: ['192.168.1.1', '2001:db8::1'])
        expect(settings).to be_valid
      end

      it 'rejects invalid IP addresses' do
        settings = build(:authorization_request_security_settings, allowed_ips: ['invalid_ip'])
        expect(settings).not_to be_valid
        expect(settings.errors[:allowed_ips]).to include('contains invalid IP or CIDR: invalid_ip')
      end

      it 'rejects invalid CIDR notation' do
        settings = build(:authorization_request_security_settings, allowed_ips: ['192.168.1.0/33'])
        expect(settings).not_to be_valid
        expect(settings.errors[:allowed_ips]).to be_present
      end
    end
  end

  describe 'uniqueness' do
    let!(:authorization_request) { create(:authorization_request) }
    let!(:existing_settings) { create(:authorization_request_security_settings, authorization_request:) }

    it 'does not allow duplicate settings for same authorization_request' do
      duplicate = build(:authorization_request_security_settings, authorization_request:)
      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
