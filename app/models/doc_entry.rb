# frozen_string_literal: true

require 'kramdown'
require 'kramdown-parser-gfm'

class DocEntry
  include ActiveModel::Model
  include ActiveModelAlgoliaSearchable

  attr_accessor :section

  # algoliasearch_active_model do
  #   attributes :title, :content, :answer_markdownify

  #   searchableAttributes %w[
  #     title
  #     content
  #     answer_markdownify
  #   ]
  # end

  def self.developers
    I18n.t('doc_entries.sections.developers').map { |entry| new(section: entry[:section]) }
  end

  def self.guide_migration
    I18n.t('doc_entries.sections.guide_migration').map { |entry| new(section: entry[:section]) }
  end
  # def self.all
  #   I18n.t('doc.sections').map { |entry| new(content: entry[:content]) }
  # end

  def self.find(slug)
    # TODO
  end

  def markdownify
    MarkdownInterpolator.new(section).perform
  end
end
