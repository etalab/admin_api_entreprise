class Token::DeliverExpirationNoticeEmails < ApplicationInteractor
  def call
    context.expiring_tokens.each do |token|
      ScheduleExpirationNoticeMailjetEmailJob.perform_later(token, expire_in)

      token.days_left_notification_sent << expire_in
      token.save
    end
  end

  private

  def expire_in
    context.expire_in
  end
end
