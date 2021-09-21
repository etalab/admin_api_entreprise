class JwtAPIEntrepriseExpirationNoticeJob < ApplicationJob
  queue_as :default

  def perform(*args)
    JwtAPIEntreprise::Operation::NotifyExpiration.call(expire_in: 90)
    JwtAPIEntreprise::Operation::NotifyExpiration.call(expire_in: 60)
    JwtAPIEntreprise::Operation::NotifyExpiration.call(expire_in: 30)
    JwtAPIEntreprise::Operation::NotifyExpiration.call(expire_in: 14)
    JwtAPIEntreprise::Operation::NotifyExpiration.call(expire_in: 7)
    JwtAPIEntreprise::Operation::NotifyExpiration.call(expire_in: 5)
    JwtAPIEntreprise::Operation::NotifyExpiration.call(expire_in: 3)
    JwtAPIEntreprise::Operation::NotifyExpiration.call(expire_in: 2)
    JwtAPIEntreprise::Operation::NotifyExpiration.call(expire_in: 1)
  end
end
