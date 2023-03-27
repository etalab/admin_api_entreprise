# frozen_string_literal: true

require 'kramdown'
require 'kramdown-parser-gfm'

class AbstractFAQEntry < ApplicationAlgoliaSearchableActiveModel
  include AbstractAPIClass

  attr_accessor :question,
    :answer,
    :category,
    :position,
    :slug

  algoliasearch_active_model do
    attributes :question, :answer_markdownify, :category

    searchableAttributes %w[
      question
      answer_markdownify
    ]

    attributesForFaceting %w[
      category
    ]
  end

  def self.all
    I18n.t("#{api}.faq.categories").each_with_object([]) do |category, array|
      entries = category[:entries].map do |entry|
        new(
          entry.merge(
            category: category[:name]
          )
        )
      end

      array.concat(entries)
    end
  end

  def self.find(slug)
    all.find do |entry|
      entry.slug == slug
    end
  end

  def self.grouped_by_categories
    all.group_by(&:category)
  end

  def initialize(params = {})
    super(params)

    @slug = params[:question].parameterize
  end

  def id
    slug
  end

  def answer_markdownify
    MarkdownInterpolator.new(answer).perform
  end
end
