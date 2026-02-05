class OpenAPIEndpoint
  attr_reader :path, :open_api_definition, :api

  def initialize(path:, open_api_definition:, api:)
    @path = path
    @open_api_definition = open_api_definition
    @api = api
  end

  def uid = path

  def title
    summary = open_api_definition['summary']
    return path if summary.blank?

    format_title(summary)
  end

  private

  def format_title(summary)
    match = summary.match(/\[(.+?)\]/)
    return summary.strip unless match

    "#{summary.gsub(/\[.*?\]/, '').strip} (#{match[1]})"
  end
end
