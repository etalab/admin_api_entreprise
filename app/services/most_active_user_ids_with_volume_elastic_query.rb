class MostActiveUserIdsWithVolumeElasticQuery
  def perform
    if Rails.env.development?
      User.last(10).pluck(:id)
    else
      $elastic.search(body: json_query, size: 0).
        dig('aggregations', 'most_active_users', 'buckets').
        map{ |bucket| [bucket['key'], bucket['doc_count']] }
    end
  end

  def json_query
    {
      "query" => {
        "bool" => {
          "must" => [
            { "match" =>  { "type" => "siade" }},
            { "range" =>  { "@timestamp" => { "gte" => "now-30d/d", "lte" => "now/d" }}}
          ]
        }
      },
      "aggs" => {
        "most_active_users" => {
          "terms" => {
            "field" => "user_access.user",
            "size" => 10
          }
        }
      }
    }
  end
end
