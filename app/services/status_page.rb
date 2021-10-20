require 'open-uri'

class StatusPage
  def current_status
    case page_summary['page']['status']
    when 'UP'
      :up
    when 'HASISSUES'
      :has_issues
    when 'UNDERMAINTENANCE'
      :maintenance
    else
      :undefined
    end
  rescue StandardError
    :undefined
  end

  private

  def page_summary
    JSON.parse(
      page_summary_body
    )
  end

  def page_summary_body
    URI.parse(page_summary_url).open.read
  end

  def page_summary_url
    'https://status.entreprise.api.gouv.fr/summary.json'
  end
end
