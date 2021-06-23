# frozen_string_literal: true

RSpec.describe Incident do
  describe 'db_indexes' do
    it { is_expected.to have_db_index(:created_at) }
  end
end
