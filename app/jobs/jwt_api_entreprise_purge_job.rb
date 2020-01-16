class JwtApiEntreprisePurgeJob < ApplicationJob
  queue_as :default

  def perform(*args)
    JwtApiEntreprise::Operation::Purge.call
  end
end
