class AbstractProvider
  include ActiveModel::Model
  include AbstractAPIClass

  attr_accessor :uid, :name, :external_link

  def self.all
    provider_i18n_backend.map { |entry| new(entry) }
  end

  def self.filter_by_uid(uids)
    all.select do |provider|
      uids.include?(provider.uid)
    end
  end

  def image_path
    "providers/#{api}/#{uid}.png"
  end

  def self.provider_i18n_backend
    I18n.t("#{api}.providers")
  end
end
