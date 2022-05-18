require 'singleton'
require 'open-uri'

class OpenAPIDefinition
  include Singleton

  attr_reader :backend

  def self.get(path)
    instance.get(path)
  end

  def get(path)
    path = backend['paths'][path]

    return unless path

    path['get']
  end

  def initialize
    load_backend
    super
  end

  def load_backend
    @backend = YAML.safe_load(open_api_definition_content)
  end

  # rubocop:disable Security/Open
  def open_api_definition_content
    URI.open(open_api_definition_url).read
  rescue StandardError => e
    Sentry.capture_exception(e)
    File.read(Rails.root.join('config/api-entreprise-v3-openapi.yml'))
  end
  # rubocop:enable Security/Open

  def open_api_definition_url
    if Rails.env.sandbox?
      'https://sandbox.entreprise.api.gouv.fr/v3/openapi.yaml'
    else
      'https://entreprise.api.gouv.fr/v3/openapi.yaml'
    end
  end
end
