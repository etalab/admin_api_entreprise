class JwtAPIEntrepriseExpirationNoticeJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Token::NotifyExpiration.call(expire_in: 90)
    Token::NotifyExpiration.call(expire_in: 60)
    Token::NotifyExpiration.call(expire_in: 30)
    Token::NotifyExpiration.call(expire_in: 14)
    Token::NotifyExpiration.call(expire_in: 7)
    Token::NotifyExpiration.call(expire_in: 0)
  end
end
