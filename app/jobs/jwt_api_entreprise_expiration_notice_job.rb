class JwtApiEntrepriseExpirationNoticeJob < ApplicationJob
  queue_as :default

  def perform(*args)
    JwtApiEntreprise::Operation::NotifyExpiration.call(expire_in: 90)
  end
end
