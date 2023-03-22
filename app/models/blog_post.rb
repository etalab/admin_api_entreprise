# frozen_string_literal: true

class BlogPost
  include ActiveModel::Model

  attr_accessor :id, :content

  def self.all
    Rails.root.glob('config/blog_posts/*.md').map do |file|
      id = File.basename(file, '.md')
      BlogPost.new(id:, content: File.read(file))
    end
  end

  def self.find(id)
    file = Rails.root.join('config/blog_posts', "#{id}.md")

    raise ActiveRecord::RecordNotFound unless File.exist?(file)

    BlogPost.new(id:, content: File.read(file))
  end
end
