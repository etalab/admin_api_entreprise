class JwtApiEntrepriseExpirationNoticeJob < ApplicationJob
  queue_as :default

  def perform(*args)
    JwtApiEntreprise::Operation::NotifyExpiration.call(expire_in: 90)
    JwtApiEntreprise::Operation::NotifyExpiration.call(expire_in: 60)
    JwtApiEntreprise::Operation::NotifyExpiration.call(expire_in: 30)
    JwtApiEntreprise::Operation::NotifyExpiration.call(expire_in: 14)
    JwtApiEntreprise::Operation::NotifyExpiration.call(expire_in: 7)
    JwtApiEntreprise::Operation::NotifyExpiration.call(expire_in: 5)
    JwtApiEntreprise::Operation::NotifyExpiration.call(expire_in: 3)
    JwtApiEntreprise::Operation::NotifyExpiration.call(expire_in: 2)
    JwtApiEntreprise::Operation::NotifyExpiration.call(expire_in: 1)
  end
end
