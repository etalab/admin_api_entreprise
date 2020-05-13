require "net/http"

module OAuthApiGouv::Tasks
  class RetrieveUserInfo < Trailblazer::Operation
    step :call_user_info_endpoint
    step :valid_response?
    fail :log_error
    step :find_related_user, Output(:failure) => End(:unknown_user)


    def call_user_info_endpoint(ctx, access_token:, **)
      uri = URI('https://auth-staging.api.gouv.fr/oauth/userinfo')
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
      user_info = JSON.parse(raw_response.body, symbolize_names: true)
      ctx[:user] = User.find_by(oauth_api_gouv_id: user_info[:sub])
    end

    def log_error(ctx, raw_response:, **)
      Rails.logger.error("OAuth User Info call failed: status #{raw_response.code}, description #{raw_response.body}")
    end
  end
end
