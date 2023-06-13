require 'singleton'
require 'open-uri'

class AbstractOpenAPIDefinition
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
    @backend = YAML.safe_load(open_api_definition_content, aliases: true, permitted_classes: [Date])
  end

  def open_api_without_deprecated_paths_definition_content
    paths = backend['paths'].dup

    paths.reject! do |_, definition|
      definition['get'] &&
        definition['get']['deprecated']
    end

    backend.merge('paths' => paths).to_yaml
  end

  # rubocop:disable Security/Open
  def open_api_definition_content
    if load_local?
      local_path.read
    else
      Rails.cache.fetch(remote_url, expires_in: 1.hour) do
        URI.open(remote_url).read
      end
    end
  rescue StandardError, OpenURI::HTTPError => e
    Sentry.capture_exception(e)
    local_path.read
  end
  # rubocop:enable Security/Open

  protected

  def local_path
    fail NotImplementedError
  end

  def remote_url
    fail NotImplementedError
  end

  private

  def load_local?
    ENV['LOAD_LOCAL_OPEN_API_DEFINITIONS'].present?
  end
end
