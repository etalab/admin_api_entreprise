class AbstractDocumentationPage
  include ActiveModel::Model
  include AbstractAPIClass

  attr_accessor :title,
    :sections

  def id
    uid
  end

  def self.find(uid)
    page_data = I18n.t!("#{api}.documentation_pages.#{uid}")

    new(
      title: page_data[:title],
      sections: page_data[:sections].map { |section| build_section(section, uid) }
    )
  rescue I18n::MissingTranslationData
    raise ActiveRecord::RecordNotFound, "Documentation page '#{uid}' does not exist"
  end

  def self.build_section(section, page_uid)
    {
      introduction: DocumentationSearchableChunk.new(section, page_uid),
      subsections: (section[:subsections] || []).map do |subsection|
        DocumentationSearchableChunk.new(subsection, page_uid)
      end
    }
  end
end
