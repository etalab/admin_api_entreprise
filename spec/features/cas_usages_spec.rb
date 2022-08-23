require 'rails_helper'

RSpec.describe 'Cas usages pages', type: :feature do
  describe 'index' do
    it 'works' do
      expect {
        visit cas_usages_path
      }.not_to raise_error
    end
  end

  describe 'show' do
    it 'works for each page' do
      I18n.t('api_entreprise.cas_usages_entries').each_key do |cas_usage_uid|
        expect {
          visit cas_usage_path(uid: cas_usage_uid)
        }.not_to raise_error, "Cas usage '#{cas_usage_uid}' is not valid"
      end
    end
  end
end
