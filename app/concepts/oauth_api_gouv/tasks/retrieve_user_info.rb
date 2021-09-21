require 'net/http'

module OAuthAPIGouv::Tasks
  class RetrieveUserInfo < Trailblazer::Operation
    step :call_user_info_endpoint
    step :valid_response?
    fail :log_error
    step :find_related_user, Output(:failure) => End(:unknown_user)
    step :update_user_api_gouv_id
    step :reconciliate_data?, Output(:failure) => End(:success)
    step :notify_datapass_for_data_reconciliation
    step :prevail_further_notifications


    def call_user_info_endpoint(ctx, access_token:, **)
      uri = URI("#{Rails.configuration.oauth_api_gouv_baseurl}/oauth/userinfo")
      ctx[:raw_response] = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        request['Authorization'] = "Bearer #{access_token}"
        http.request(request)
      end
    end

    def valid_response?(ctx, raw_response:, **)
      raw_response.code == '200'
    end

    def find_related_user(ctx, raw_response:, **)
      ctx[:user_info] = JSON.parse(raw_response.body, symbolize_names: true)
      ctx[:user] = User.find_by(email: ctx[:user_info][:email])
    end

    def log_error(ctx, raw_response:, **)
      Rails.logger.error("OAuth User Info call failed: status #{raw_response.code}, description #{raw_response.body}")
    end

    def reconciliate_data?(ctx, user:, **)
      user.tokens_newly_transfered?
    end

    def update_user_api_gouv_id(ctx, user:, user_info:, **)
      user.update(oauth_api_gouv_id: user_info[:sub])
    end

    def notify_datapass_for_data_reconciliation(ctx, user:, **)
      UserMailer.notify_datapass_for_data_reconciliation(user).deliver_later
    end

    def prevail_further_notifications(ctx, user:, **)
      user.update(tokens_newly_transfered: false)
    end
  end
end
