# frozen_string_literal: true

class DocumentationEntrySection < ApplicationAlgoliaSearchableActiveModel
  include ActiveModel::Model

  attr_accessor :subtitle, :subtitle_anchor, :content, :page

  algoliasearch_active_model do
    attributes :subtitle, :content_markdown, :page

    searchableAttributes %w[
      subtitle
      content_markdown
    ]

    attributesForFaceting %w[
      page
    ]
  end

  def initialize(section, page)
    @subtitle = section[:subtitle]
    @subtitle_anchor = section[:subtitle_anchor]
    @content = section[:content]
    @page = page
  end

  def self.all
    guide_migration + developers
  end

  def self.guide_migration
    DocumentationEntry.guide_migration.map(&:sections).compact.flatten
  end

  def self.developers
    DocumentationEntry.developers.map(&:sections).compact.flatten
  end

  def id
    subtitle_anchor
  end

  def content_markdown
    MarkdownInterpolator.new(content).perform
  end
end
