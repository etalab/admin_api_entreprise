require 'erb'
require 'kramdown'

class MarkdownInterpolator
  include Rails.application.routes.url_helpers

  def initialize(content)
    @content = content
  end

  def perform
    return '' if @content.blank?

    Kramdown::Document.new(
      content_interpolated,
      input: 'GFM',
      parse_block_html: true
    ).to_html
  end

  def content_interpolated
    ERB.new(@content).result(binding)
  end

  def image_path(name)
    ActionController::Base.helpers.image_path(name)
  end
end
