class MigrateLegacyTokenService
  attr_reader :tokens

  def initialize(tokens)
    @tokens = tokens
  end

  def perform
    tokens.each do |token|
      next unless token.legacy_token? && !token.legacy_token_migrated?

      mark_token_as_migrated!(token)
    end
  end

  private

  def mark_token_as_migrated!(token)
    token.extra_info['legacy_token_migrated'] = 't'

    token.save!
  end
end
