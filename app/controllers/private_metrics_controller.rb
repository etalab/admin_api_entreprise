class PrivateMetricsController < ApplicationController
  skip_before_action :jwt_authenticate!

  def index
    all_jwt = JwtApiEntreprise.all

    render json: {
      unused_jwt_list: unused_jwt_list
    }, status: 200
  end

  private
  def unused_jwt_list
    JwtApiEntreprise.where.not(id: used_jti)
  end

  def used_jti
    client = ElasticClient.new
    client.establish_connection

    client.search(used_jti_query, size: 0)

    client.raw_response.dig('aggregations', 'unique-jti', 'buckets').map{ |bucket| bucket['key'] }
  end

  def used_jti_query
    {
      "query" => {
        "bool" => {
          "must": [
            { "match" =>  { "type" => "siade" }},
            { "range" =>  { "@timestamp" => { "gte" => "now-730d/d", "lte" => "now/d" }}}
          ]
        }
      },
      "aggs" => {
        "unique-jti" => {
          "terms" => {
            "field" => "user_access.jti",
            "size"=> 50000
          }
        }
      }
    }
  end
end

