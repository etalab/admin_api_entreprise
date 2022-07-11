# frozen_string_literal: true

class DocumentationEntry < ApplicationAlgoliaSearchableActiveModel
  include ActiveModel::Model

  attr_accessor :section, :title, :content, :anchor, :category

  algoliasearch_active_model do
    attributes :section, :title, :content_markdownify, :category

    searchableAttributes %w[
      section
      title
      content_markdownify
    ]

    attributesForFaceting %w[
      category
    ]
  end

  def self.all
    developers + guide_migration
  end

  def id
    anchor
  end

  def self.developers
    I18n.t('documentation_entries.sections.developers').map do |entry|
      new(title: entry[:title], content: entry[:content], anchor: entry[:anchor], category: 'developers')
    end
  end

  def self.guide_migration
    I18n.t('documentation_entries.sections.guide_migration').map do |entry|
      new(title: entry[:title], content: entry[:content], anchor: entry[:anchor], category: 'guide_migration')
    end
  end

  def content_markdownify
    MarkdownInterpolator.new(content).perform
  end
end
