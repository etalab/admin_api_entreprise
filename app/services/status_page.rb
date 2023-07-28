require 'open-uri'

class StatusPage
  def current_status
    case raw_current_status
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

  def raw_current_status
    cache.read(cache_key) ||
      retrieve_from_status_page
  end

  def retrieve_from_status_page
    status = page_summary['page']['status']

    cache.write(cache_key, status, expires_in: 5.minutes.to_i)

    status
  end

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

  def cache_key
    'status_page_current_status'
  end

  def cache
    @cache ||= Rails.cache
  end
end
