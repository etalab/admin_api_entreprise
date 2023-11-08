# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Blog', app: :api_particulier do
  describe 'show one article' do
    subject(:show_blog_post) { visit blog_post_path(id: uid) }

    context 'with valid uid' do
      let(:uid) { 'hello-world' }
      let(:valid_text) { 'Hello world' }

      it 'does not raise error' do
        expect {
          show_blog_post
        }.not_to raise_error
      end

      it 'renders the blog post' do
        show_blog_post

        expect(page).to have_content(valid_text)
      end
    end

    context 'with invalid uid' do
      let(:uid) { 'invalid' }

      it 'raises a routing error' do
        show_blog_post

        expect(page).to have_current_path(root_path, ignore_query: true)
      end
    end
  end
end
