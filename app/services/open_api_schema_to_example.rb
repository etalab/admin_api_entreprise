class OpenAPISchemaToExample
  attr_reader :schema

  def initialize(schema)
    @schema = schema
  end

  def perform # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
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
    when 'integer'
      extract_value(schema, rand(50))
    when 'boolean'
      extract_value(schema, true)
    else
      'ipsum'
    end
  end

  private

  def extract_value(sub_schema, default)
    sub_schema['example'] ||
      default
  end
end
