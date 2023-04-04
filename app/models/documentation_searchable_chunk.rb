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
    %w[entreprise particulier].each_with_object([]) do |api, searchable_chunks|
      I18n.t!("api_#{api}.documentation_pages").each do |page_uid, page_data|
        page_data[:sections].each do |section|
          (section[:subsections] || []).each do |subsection|
            searchable_chunks << new(subsection, page_uid)
          end

          searchable_chunks << new(section, page_uid)
        end
      end
    end
  end

  def id
    anchor
  end
end
