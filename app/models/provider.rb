class Provider
  include ActiveModel::Model

  attr_accessor :slug, :name

  def self.all
    I18n.t('providers').map do |slug, name|
      new(slug:, name:)
    end
  end
end
