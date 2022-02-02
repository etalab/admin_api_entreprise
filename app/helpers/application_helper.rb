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
      Kramdown::Document.new(
        content,
        input: 'GFM',
        parse_block_html: true
      ).to_html.html_safe
    end
  end

  def swagger_url(anchor)
    "https://entreprise.api.gouv.fr/v3/developers/index.html##{anchor}"
  end

  def boolean_i18n(value)
    i18n_key = value ? 'yes' : 'no'
    I18n.t(i18n_key)
  end

  def icon(kind)
    "<span class=\"icon #{kind}\" aria-hidden=\"true\"></span>".html_safe
  end
end
