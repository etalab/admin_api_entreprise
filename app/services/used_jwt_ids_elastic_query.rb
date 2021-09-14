class UsedJwtIdsElasticQuery
  def initialize(number_of_days_from_now = 730)
    @number_of_days_from_now = number_of_days_from_now
  end

  def perform
    if Rails.env.development?
      [UsersQuery.new.with_token.results.first.jwt_api_entreprise.first.id]
    else
      $elastic.search(body: used_jti_ids_json_query, size: 0).dig('aggregations', 'unique-jti', 'buckets').map{ |bucket| bucket['key'] }
    end
  end

  def used_jti_ids_json_query
    {
      "query" => {
        "bool" => {
          "must": [
            { "match" =>  { "type" => "siade" }},
            { "range" =>  { "@timestamp" => { "gte" => "now-#{@number_of_days_from_now}d/d", "lte" => "now/d" }}}
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
