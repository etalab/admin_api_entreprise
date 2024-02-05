class User
  class NotifyDatapassOfTokenOwnership < ApplicationInteractor
    def call
      return unless first_login_after_token_transfer?

      mailer_klass.notify_datapass_for_data_reconciliation(context.user, context.namespace).deliver_later
      context.user.update(tokens_newly_transfered: false)
    end

    private

    def mailer_klass
      "#{context.namespace.classify}::UserMailer".constantize
    end

    def first_login_after_token_transfer?
      context.user.tokens_newly_transfered?
    end
  end
end
