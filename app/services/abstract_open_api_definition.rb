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
    @backend = YAML.safe_load(open_api_definition_content)
  end

  # rubocop:disable Security/Open
  def open_api_definition_content
    URI.open(remote_url).read
  rescue StandardError => e
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
end
