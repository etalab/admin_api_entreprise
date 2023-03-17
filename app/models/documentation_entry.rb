# frozen_string_literal: true

class DocumentationEntry
  include ActiveModel::Model

  attr_accessor :title, :introduction, :sections, :anchor, :page

  def self.all
    developers + guide_migration
  end

  def id
    anchor
  end

  def self.developers
    build_from_yaml('developers')
  end

  def self.guide_migration
    build_from_yaml('guide_migration')
  end

  def self.build_from_yaml(page)
    I18n.t("api_entreprise.documentation_entries.pages.#{page}").map do |entry|
      new(
        title: entry[:title],
        introduction: entry[:introduction] || '',
        sections: entry[:sections]&.map { |section| DocumentationEntrySection.new(section, page) } || [],
        anchor: entry[:anchor],
        page:
      )
    end
  end

  def introduction_markdown
    MarkdownInterpolator.new(introduction).perform
  end
end
