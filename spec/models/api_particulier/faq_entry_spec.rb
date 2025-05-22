# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/models/faq_entry'

RSpec.describe APIParticulier::FAQEntry do
  it_behaves_like 'a faq entry model'
end
