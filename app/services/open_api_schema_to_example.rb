class OpenAPISchemaToExample
  attr_reader :schema

  def initialize(schema)
    @schema = schema
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
  def perform
    case schema['type']
    when 'array'
      [
        self.class.new(schema['items']).perform
      ].flatten
    when 'object'
      schema['properties'].to_h.transform_values do |value|
        self.class.new(value).perform
      end
    when 'string'
      extract_value(schema, 'lorem')
    when 'integer', 'number'
      extract_value(schema, rand(50))
    when 'boolean'
      extract_value(schema, true)
    when 'date'
      extract_value(schema, Time.zone.today.to_s)
    else
      'ipsum'
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength

  private

  def extract_value(sub_schema, default)
    sub_schema['example'] ||
      default
  end
end
