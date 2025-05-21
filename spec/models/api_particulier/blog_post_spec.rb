# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/models/blog_post'

RSpec.describe APIParticulier::BlogPost do
  it_behaves_like 'a blog post model'
end
