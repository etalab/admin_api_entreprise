# frozen_string_literal: true

RSpec.shared_examples 'a documentation feature' do
  describe 'developers' do
    it 'does not raise error' do
      expect {
        visit developers_path
      }.not_to raise_error
    end
  end
end
