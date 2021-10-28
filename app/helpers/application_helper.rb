require 'kramdown'
require 'kramdown-parser-gfm'

module ApplicationHelper
  def status_to_color(status)
    case status
    when :up
      'success'
    when :has_issues
      'error'
    when :maintenance
      'info'
    else
      'undefined'
    end
  end

  def markdown_to_html(content)
    content_tag(:div, class: %(markdown-wrapper)) do
      Kramdown::Document.new(
        content,
        input: 'GFM',
        parse_block_html: true
      ).to_html.html_safe
    end
  end
end
