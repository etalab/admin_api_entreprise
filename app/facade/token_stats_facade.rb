class TokenStatsFacade
  def initialize(token)
    @token = token
  end

  def stats_metabase_urls
    @stats_metabase_urls ||= {
      last_10_minutes: build_stats('10 minutes'),
      last_30_hours: build_stats('30 hours'),
      last_8_days: build_stats('8 days')
    }
  end

  def last_requests_metabase_url
    @last_requests_metabase_url ||= MetabaseEmbedService.new(178, { token_id:, limit: last_requests_limit }).url
  end

  def last_requests_limit
    10
  end

  private

  def build_stats(interval)
    MetabaseEmbedService.new(177, build_params(interval)).url
  end

  def question_id
    177
  end

  def build_params(interval)
    {
      token_id:,
      interval:
    }
  end

  def token_id
    @token.id
  end
end
