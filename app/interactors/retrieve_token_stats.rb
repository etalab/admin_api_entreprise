require 'open-uri'

class RetrieveTokenStats < ApplicationInteractor
  def call
    context.token = JwtAPIEntreprise.find(context.token_id)
    retrieve_stats!
    format_stats_data!
  rescue ActiveRecord::RecordNotFound
    fail!('Token not found', 'error')
  end

  private

  def retrieve_stats!
    context.raw_stats = JSON.parse(raw_body, symbolize_names: true)
  rescue StandardError
    fail!('Watchdoge error', 'error')
  end

  def raw_body
    URI.parse(stats_url).open.read
  end

  def stats_url
    "https://dashboard.entreprise.api.gouv.fr/api/watchdoge/stats/jwt_usage/#{context.token_id}"
  end

  def format_stats_data!
    context.stats = {
      last_8_days: context.raw_stats[:apis_usage][:last_8_days][:by_endpoint],
      last_requests: context.raw_stats[:last_calls]
    }
  end
end
