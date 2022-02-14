class NotInProductionJwtIdsElasticQuery
  def perform
    if Rails.env.development?
      [UsersQuery.new.with_token.results.first.jwt_api_entreprise.first.id]
    else
      $elastic.search(body: json_query, size: 0)
        .dig('aggregations', 'production-delayed-jti', 'buckets').map { |bucket| bucket['key'] }
    end
  end

  def json_query
    {
      'query' => {
        'bool' => {
          'must' => [
            { 'match' =>  { 'type' => 'siade' } },
            { 'range' =>  { '@timestamp' => { 'gte' => 'now-730d/d', 'lte' => 'now/d' } } }
          ]
        }
      },
      'aggs' => {
        'production-delayed-jti' => {
          'terms' => {
            'field' => 'user_access.jti',
            'size' => 5000
          },
          'aggs' => {
            'unique_siren' => {
              'cardinality' => {
                'field' => 'parameters.siren.keyword'
              }
            },
            'unique_siret' => {
              'cardinality' => {
                'field' => 'parameters.siret.keyword'
              }
            },
            'unique_rna' => {
              'cardinality' => {
                'field' => 'parameters.siret_or_eori.keyword'
              }
            },
            'unique_ids_count' => {
              'bucket_script' => {
                'buckets_path' => {
                  'siren_count' => 'unique_siren',
                  'siret_count' => 'unique_siret',
                  'rna_count' => 'unique_rna'
                },
                'script' => '(int)(params.siren_count + params.siret_count + params.rna_count)'
              }
            },
            'f' => {
              'bucket_selector' => {
                'buckets_path' => { 'unique_ids_count' => 'unique_ids_count' },
                'script' => 'params.unique_ids_count < 20'
              }
            }
          }
        }
      }
    }
  end
end
