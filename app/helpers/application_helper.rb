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

  def site_v3?
    request.subdomain.split('.')[0] == 'v3-beta'
  end

  def markdown_to_html(content)
    content_tag(:div, class: %(markdown-wrapper)) do
      MarkdownInterpolator.new(content).perform.html_safe
    end
  end

  def boolean_i18n(value)
    i18n_key = value ? 'yes' : 'no'
    I18n.t(i18n_key)
  end

  def icon(kind)
    "<span class=\"icon #{kind}\" aria-hidden=\"true\"></span>".html_safe
  end
end
