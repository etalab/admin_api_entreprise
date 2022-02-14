class JwtAPIEntrepriseExpirationNoticeJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    Token::SendExpirationNotices.call(expire_in: 90)
    Token::SendExpirationNotices.call(expire_in: 60)
    Token::SendExpirationNotices.call(expire_in: 30)
    Token::SendExpirationNotices.call(expire_in: 14)
    Token::SendExpirationNotices.call(expire_in: 7)
    Token::SendExpirationNotices.call(expire_in: 0)
  end
end
