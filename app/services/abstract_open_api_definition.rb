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

  # rubocop:disable Security/Open
  def open_api_definition_content
    if load_local?
      local_path.read
    else
      URI.open(remote_url).read
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
