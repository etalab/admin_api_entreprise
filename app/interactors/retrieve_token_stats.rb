require 'open-uri'

class RetrieveTokenStats < ApplicationInteractor
  def call
    context.token = Token.find(context.token_id)
    retrieve_stats!
    format_stats_data!
  rescue ActiveRecord::RecordNotFound
    fail!('not_found', 'warning')
  end

  private

  def retrieve_stats!
    context.raw_stats = JSON.parse(raw_body, symbolize_names: true)
  rescue StandardError
    fail!('stats_backend', 'error')
  end

  def raw_body
    URI.parse(stats_url).open.read
  end

  def stats_url
    "https://dashboard.entreprise.api.gouv.fr/api/watchdoge/stats/token_usage/#{context.token_id}"
  end

  def format_stats_data!
    context.stats = {
      last_10_minutes: context.raw_stats[:apis_usage][:last_10_minutes][:by_endpoint],
      last_30_hours: context.raw_stats[:apis_usage][:last_30_hours][:by_endpoint],
      last_8_days: context.raw_stats[:apis_usage][:last_8_days][:by_endpoint],
      last_requests: context.raw_stats[:last_calls]
    }
  end
end
