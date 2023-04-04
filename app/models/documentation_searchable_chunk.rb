class DocumentationSearchableChunk < ApplicationAlgoliaSearchableActiveModel
  attr_reader :id
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

  def initialize(section, api_page_uid)
    @title = section[:title]
    @anchor = section[:anchor] || section[:title].parameterize
    @content = MarkdownInterpolator.new(section[:content]).perform
    @page = api_page_uid
    @id = "#{api_page_uid}_#{anchor}"
  end

  def self.all
    %w[entreprise particulier].each_with_object([]) do |api, searchable_chunks|
      I18n.t!("api_#{api}.documentation_pages").each do |page_uid, page_data|
        page_data[:sections].each do |section|
          (section[:subsections] || []).each do |subsection|
            searchable_chunks << new(subsection, "api_#{api}_#{page_uid}")
          end

          searchable_chunks << new(section, "api_#{api}_#{page_uid}")
        end
      end
    end
  end
end
