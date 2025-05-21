# frozen_string_literal: true

RSpec.shared_examples 'a cas usages feature' do |api_module, path_prefix = nil|
  let(:cas_usages_class) { api_module::CasUsage }
  let(:index_path_method) { path_prefix ? "#{path_prefix}_cas_usages_path" : 'cas_usages_path' }
  let(:show_path_method) { path_prefix ? "#{path_prefix}_cas_usage_path" : 'cas_usage_path' }

  describe 'index' do
    it 'does not raise error' do
      expect {
        visit send(index_path_method)
      }.not_to raise_error
    end
  end

  describe 'show' do
    it 'does not raise error' do
      cas_usages_class.all.each do |cas_usage|
        visit send(show_path_method, uid: cas_usage.uid)
        expect(page).to have_current_path(send(show_path_method, cas_usage.uid), ignore_query: true)
      end
    end

    it 'redirects to root path when cas_usage is not found' do
      visit send(show_path_method, uid: '0123456789')
      expect(page).to have_current_path root_path
    end
  end
end
