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

  def main_site?
    request.subdomain.split('.')[0] != 'dashboard'
  end

  def markdown_to_html(content)
    return unless content

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

  def datapass_renewal_url(token)
    "#{Rails.configuration.token_renewal_url}#{token.authorization_request.external_id}"
  end

  def datapass_authorization_request_url(authorization_request)
    "#{Rails.configuration.token_authorization_request_url}#{authorization_request.external_id}"
  end
end
