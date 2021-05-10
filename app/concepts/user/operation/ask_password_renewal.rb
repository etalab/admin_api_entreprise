module User::Operation
  class AskPasswordRenewal < Trailblazer::Operation
    step self::Contract::Validate(constant: User::Contract::AskPasswordRenewal)
    fail :validation_errors, fail_fast: true
    step :retrieve_user_from_email
    step :generate_a_renewal_token
    step :add_timestamp
    step :send_renewal_email


    def retrieve_user_from_email(ctx, params:, **)
      ctx[:user] = User.find_by_email(params[:email])
    end

    def generate_a_renewal_token(ctx, user:, **)
      user.generate_pwd_renewal_token
    end

    def add_timestamp(ctx, user:, **)
      user.update(pwd_renewal_token_sent_at: Time.zone.now)
    end

    def send_renewal_email(ctx, user:, **)
      UserMailer.renew_account_password(user).deliver_later
    end

    def validation_errors(ctx, **)
      ctx[:errors] = {} if ctx[:errors].nil?
      ctx[:errors].merge!(ctx['result.contract.default'].errors)
    end
  end
end
