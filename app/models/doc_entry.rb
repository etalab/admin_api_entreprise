# frozen_string_literal: true

require 'kramdown'
require 'kramdown-parser-gfm'

class DocEntry
  include ActiveModel::Model
  include ActiveModelAlgoliaSearchable

  attr_accessor :section, :title, :content

  def self.developers
    I18n.t('doc_entries.sections.developers').map { |entry| new(title: entry[:title], content: entry[:content]) }
  end

  def self.guide_migration
    I18n.t('doc_entries.sections.guide_migration').map { |entry| new(title: entry[:title], content: entry[:content]) }
  end

  def anchor
    title.parameterize
  end

  def content_markdownify
    MarkdownInterpolator.new(content).perform
  end
end
