class AccessLogsCounts
  attr_reader :tokens

  def initialize(tokens)
    @tokens = tokens
  end

  def [](token)
    counts[token.id] || 0
  end

  private

  def counts
    @counts ||= AccessLog.where(token_id: tokens).group(:token_id).count
  end
end
