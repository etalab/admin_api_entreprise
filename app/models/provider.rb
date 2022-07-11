class Provider
  include ActiveModel::Model

  attr_accessor :slug, :name, :external_link

  def self.all
    I18n.t('providers').map { |entry| new(entry) }
  end
end
