require 'open-uri'

class TokenStatsService
  def initialize(token_id)
    @token_id = token_id
  end

  def stats_for_period(period)
    stats_data&.dig(:apis_usage, period)
  end

  def last_requests_details
    stats_data&.dig(:last_calls)
  end

  private

  def stats_data
    @stats_data ||= JSON.parse(raw_stats, symbolize_names: true)
  rescue StandardError
    nil
  end

  def raw_stats
    URI.parse(stats_url).open.read
  end

  def stats_url
    "https://dashboard.entreprise.api.gouv.fr/api/watchdoge/stats/jwt_usage/#{@token_id}"
  end
end
