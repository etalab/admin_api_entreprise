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
    redis.get(redis_cached_key) ||
      retrieve_from_status_page
  end

  def retrieve_from_status_page
    status = page_summary['page']['status']

    redis.set(redis_cached_key, status, ex: 5.minutes.to_i)

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

  def redis_cached_key
    'status_page_current_status'
  end

  def redis
    @redis ||= Redis.new(host: redis_host, post: 6379, db: 0)
  end

  def redis_host
    ENV.fetch('REDIS_HOST') { 'localhost' }
  end
end
