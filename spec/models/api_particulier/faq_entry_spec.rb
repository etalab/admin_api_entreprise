# frozen_string_literal: true

require 'rails_helper'

RSpec.describe APIParticulier::FAQEntry do
  describe '.all' do
    subject(:faq_entries) { described_class.all }

    it { expect(faq_entries.count).to be >= 1 }

    describe 'one element' do
      subject(:faq_entry) { described_class.all.first }

      it { is_expected.to be_a(described_class) }
      it { expect(faq_entry.slug).to be_present }
    end
  end
end
