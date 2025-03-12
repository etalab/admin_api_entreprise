class AbstractProvider
  include ActiveModel::Model
  include AbstractAPIClass

  attr_accessor :uid,
    :name,
    :external_link

  attr_writer :scopes

  def self.find(uid)
    all.find { |provider| provider.uid == uid }
  end

  def self.all
    provider_i18n_backend.map { |entry| new(entry) }
  end

  def self.filter_by_uid(uids)
    all.select do |provider|
      uids.include?(provider.uid)
    end
  end

  def scopes
    @scopes || []
  end

  def routes
    open_api_definition_singleton.routes.select do |path|
      path.include?(uid)
    end
  end

  def users
    User.where('provider_uids @> ARRAY[?]::varchar[]', uid)
  end

  def image_path
    "providers/#{api}/#{uid}.png"
  end

  def self.provider_i18n_backend
    I18n.t("#{api}.providers")
  end

  private

  def open_api_definition_singleton
    @open_api_definition_singleton ||= Kernel.const_get(self.class.name.split('::')[0])::OpenAPIDefinition.instance
  end
end
