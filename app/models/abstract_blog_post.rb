class AbstractBlogPost
  include ActiveModel::Model
  include AbstractAPIClass

  attr_accessor :id, :content

  def self.find(id)
    file = Rails.root.join('config/blog_posts', api, "#{id}.md")

    raise ActiveRecord::RecordNotFound unless File.exist?(file)

    new(id:, content: File.read(file))
  end

  def self.all
    blog_posts_files.map do |file|
      id = File.basename(file, '.md')

      new(id:, content: File.read(file))
    end
  end

  def self.blog_posts_files
    Dir[Rails.root.join('config/blog_posts', api, '*.md')]
  end
end
