# frozen_string_literal: true

require 'kramdown'
require 'kramdown-parser-gfm'

class AbstractFAQEntry
  include AbstractAPIClass
  include ActiveModel::Model

  attr_accessor :question,
    :answer,
    :category,
    :position,
    :slug

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
    super

    @slug = params[:question].parameterize
  end

  def id
    @id ||= slug.gsub('/', '_')
  end

  def answer_markdownify
    MarkdownInterpolator.new(answer).perform
  end
end
