require 'rails_helper'

RSpec.describe 'Cas usages pages', app: :api_entreprise do
  describe 'index' do
    it 'does not raise error' do
      expect {
        visit cas_usages_path
      }.not_to raise_error
    end
  end

  describe 'show' do
    it 'does not raise error' do
      APIEntreprise::CasUsage.all.each do |cas_usage|
        visit cas_usage_path(uid: cas_usage.uid)
        expect(page).to have_current_path(cas_usage_path(cas_usage.uid), ignore_query: true)
      end
    end

    it 'redirects to root path when cas_usage is not found' do
      visit cas_usage_path(uid: '0123456789')
      expect(page).to have_current_path root_path
    end
  end
end
