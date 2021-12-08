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

  def open_api_definition_content
    URI.open('https://entreprise.api.gouv.fr/v3/openapi.yaml')
  rescue StandardError
    File.read(Rails.root.join('config/api-entreprise-v3-openapi.yml'))
  end
end
