# frozen_string_literal: true

class DocumentationEntry < ApplicationAlgoliaSearchableActiveModel
  attr_accessor :section, :title, :content, :anchor

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
