# frozen_string_literal: true

class DocumentationEntry < ApplicationAlgoliaSearchableActiveModel
  include ActiveModel::Model

  attr_accessor :section, :title, :content, :anchor

  algoliasearch_active_model do
    attributes :section, :title, :content_markdownify

    searchableAttributes %w[
      section
      title
      content_markdownify
    ]
  end

  def self.all
    developers #TODO find a solution for multiple entry categories (guide migration)
  end

  def id
    anchor
  end

  def self.developers
    I18n.t('documentation_entries.sections.developers').map { |entry| new(title: entry[:title], content: entry[:content], anchor: entry[:anchor]) }
  end

  def self.guide_migration
    I18n.t('documentation_entries.sections.guide_migration').map { |entry| new(title: entry[:title], content: entry[:content], anchor: entry[:anchor]) }
  end

  def content_markdownify
    MarkdownInterpolator.new(content).perform
  end
end
