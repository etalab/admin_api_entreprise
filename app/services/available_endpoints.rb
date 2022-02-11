require 'singleton'

class AvailableEndpoints
  include Singleton

  def self.all
    instance.backend
  end

  def self.find(uid)
    instance.backend.find do |endpoint|
      endpoint['uid'] == uid
    end
  end

  def backend
    load_backend if Rails.env.development?
    @backend
  end

  private

  def initialize
    load_backend
    super
  end

  def load_backend
    @backend = endpoints_files.inject([]) do |array, endpoint_file|
      array.concat(YAML.safe_load(File.read(endpoint_file), aliases: true))
    end.sort do |e1, e2|
      order_by_position(e1, e2)
    end.map do |endpoint|
      endpoint.except('position')
    end
  end

  def endpoints_files
    Dir["#{Rails.root.join('config/endpoints/')}*.yml"]
  end

  def order_by_position(e1, e2)
    (e1['position'] || 900_001) <=> (e2['position'] || 900_001)
  end
end
