class Token::DeliverExpirationNoticeEmails < ApplicationInteractor
  def call
    context.expiring_tokens.each do |jwt|
      ScheduleExpirationNoticeMailjetEmailJob.perform_later(jwt, expire_in)

      jwt.days_left_notification_sent << expire_in
      jwt.save
    end
  end

  private

  def expire_in
    context.expire_in
  end
end
