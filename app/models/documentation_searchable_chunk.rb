class DocumentationSearchableChunk < ApplicationAlgoliaSearchableActiveModel
  attr_accessor :title, :anchor, :content, :page

  algoliasearch_active_model do
    attributes :title, :content, :page

    searchableAttributes %w[
      title
      content
    ]

    attributesForFaceting %w[
      page
    ]
  end

  def initialize(section, page_uid)
    @title = section[:title]
    @anchor = section[:anchor] || section[:title].parameterize
    @content = MarkdownInterpolator.new(section[:content]).perform
    @page = page_uid
  end

  def self.all
    I18n.t!('api_entreprise.documentation_pages').each_with_object([]) do |(page_uid, page_data), searchable_chunks|
      page_data[:sections].each do |section|
        (section[:subsections] || []).each do |subsection|
          searchable_chunks << new(subsection, page_uid)
        end

        searchable_chunks << new(section, page_uid) if section[:content].present?
      end
    end
  end

  def id
    anchor
  end
end
