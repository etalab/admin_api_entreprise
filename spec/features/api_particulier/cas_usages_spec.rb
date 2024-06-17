require 'rails_helper'

RSpec.describe 'Cas usages pages', app: :api_particulier do
  describe 'index' do
    it 'does not raise error' do
      expect {
        visit api_particulier_cas_usages_path
      }.not_to raise_error
    end
  end

  describe 'show' do
    it 'does not raise error and' do
      APIParticulier::CasUsage.all.each do |cas_usage|
        visit api_particulier_cas_usage_path(uid: cas_usage.uid)

        expect(page).to have_current_path(api_particulier_cas_usage_path(cas_usage.uid), ignore_query: true)
      end
    end

    it 'redirects to root path when cas_usage is not found' do
      visit api_particulier_cas_usage_path(uid: '0123456789')
      expect(page).to have_current_path root_path
    end
  end
end
