require 'faraday'

class AbstractINSEEAPIClient
  protected

  def http_connection(&block)
    @http_connection ||= Faraday.new do |conn|
      conn.request :retry, max: 5
      conn.response :raise_error
      conn.response :json
      conn.options.timeout = 2
      yield(conn) if block
    end
  end

  def consumer_key
    Rails.application.credentials.insee_consumer_key
  end

  def consumer_secret
    Rails.application.credentials.insee_consumer_secret
  end
end
